use crate::error::{AppError, AppResult};
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use std::fs;
use dirs;

#[derive(Debug, Serialize, Deserialize)]
pub struct Config {
    pub default_profile: Option<String>,
    pub sso_start_url: Option<String>,
    pub sso_region: Option<String>,
    pub roles: Vec<RoleConfig>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct RoleConfig {
    pub name: String,
    pub role_arn: String,
    pub account_id: String,
    pub source_profile: Option<String>,
}

impl Config {
    pub fn load() -> AppResult<Self> {
        let config_path = Self::get_config_path()?;
        if !config_path.exists() {
            return Ok(Config {
                default_profile: None,
                sso_start_url: None,
                sso_region: None,
                roles: Vec::new(),
            });
        }

        let content = fs::read_to_string(&config_path)
            .map_err(|e| AppError::ConfigError(format!("Failed to read config file: {}", e)))?;

        serde_json::from_str(&content)
            .map_err(|e| AppError::ConfigError(format!("Failed to parse config file: {}", e)))
    }

    pub fn save(&self) -> AppResult<()> {
        let config_path = Self::get_config_path()?;
        
        // Ensure the config directory exists
        if let Some(parent) = config_path.parent() {
            fs::create_dir_all(parent)
                .map_err(|e| AppError::ConfigError(format!("Failed to create config directory: {}", e)))?;
        }

        let content = serde_json::to_string_pretty(self)
            .map_err(|e| AppError::ConfigError(format!("Failed to serialize config: {}", e)))?;

        fs::write(&config_path, content)
            .map_err(|e| AppError::ConfigError(format!("Failed to write config file: {}", e)))?;

        Ok(())
    }

    fn get_config_path() -> AppResult<PathBuf> {
        let home_dir = dirs::home_dir()
            .ok_or_else(|| AppError::ConfigError("Could not find home directory".to_string()))?;
        
        Ok(home_dir.join(".aws-assume-role").join("config.json"))
    }

    pub fn add_role(&mut self, role: RoleConfig) {
        if let Some(existing) = self.roles.iter_mut().find(|r| r.name == role.name) {
            *existing = role;
        } else {
            self.roles.push(role);
        }
    }

    pub fn get_role(&self, name: &str) -> Option<&RoleConfig> {
        self.roles.iter().find(|r| r.name == name)
    }

    pub fn remove_role(&mut self, name: &str) -> bool {
        if let Some(pos) = self.roles.iter().position(|r| r.name == name) {
            self.roles.remove(pos);
            true
        } else {
            false
        }
    }
}
