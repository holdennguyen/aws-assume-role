use crate::error::{AppError, AppResult};

use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;

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
    pub session_duration: Option<i64>,
}

impl Default for Config {
    fn default() -> Self {
        Self::new()
    }
}

impl Config {
    pub fn new() -> Self {
        Self {
            default_profile: None,
            sso_start_url: None,
            sso_region: None,
            roles: Vec::new(),
        }
    }

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
            fs::create_dir_all(parent).map_err(|e| {
                AppError::ConfigError(format!("Failed to create config directory: {}", e))
            })?;
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

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use tempfile::TempDir;

    #[test]
    fn test_role_config_creation() {
        let role = RoleConfig {
            name: "test-role".to_string(),
            role_arn: "arn:aws:iam::123456789012:role/TestRole".to_string(),
            account_id: "123456789012".to_string(),
            source_profile: None,
            session_duration: Some(3600),
        };

        assert_eq!(role.name, "test-role");
        assert_eq!(role.role_arn, "arn:aws:iam::123456789012:role/TestRole");
        assert_eq!(role.account_id, "123456789012");
        assert_eq!(role.session_duration, Some(3600));
    }

    #[test]
    fn test_config_creation() {
        let config = Config::new();
        assert!(config.roles.is_empty());
    }

    #[test]
    fn test_add_role() {
        let mut config = Config::new();
        let role = RoleConfig {
            name: "test-role".to_string(),
            role_arn: "arn:aws:iam::123456789012:role/TestRole".to_string(),
            account_id: "123456789012".to_string(),
            source_profile: None,
            session_duration: Some(3600),
        };

        config.add_role(role);
        assert_eq!(config.roles.len(), 1);
        assert!(config.get_role("test-role").is_some());
    }

    #[test]
    fn test_get_role() {
        let mut config = Config::new();
        let role = RoleConfig {
            name: "test-role".to_string(),
            role_arn: "arn:aws:iam::123456789012:role/TestRole".to_string(),
            account_id: "123456789012".to_string(),
            source_profile: None,
            session_duration: Some(3600),
        };

        config.add_role(role);

        let retrieved_role = config.get_role("test-role");
        assert!(retrieved_role.is_some());
        assert_eq!(retrieved_role.unwrap().name, "test-role");

        let non_existent = config.get_role("non-existent");
        assert!(non_existent.is_none());
    }

    #[test]
    fn test_remove_role() {
        let mut config = Config::new();
        let role = RoleConfig {
            name: "test-role".to_string(),
            role_arn: "arn:aws:iam::123456789012:role/TestRole".to_string(),
            account_id: "123456789012".to_string(),
            source_profile: None,
            session_duration: Some(3600),
        };

        config.add_role(role);
        assert_eq!(config.roles.len(), 1);

        let removed = config.remove_role("test-role");
        assert!(removed);
        assert_eq!(config.roles.len(), 0);

        let not_removed = config.remove_role("non-existent");
        assert!(!not_removed);
    }

    #[test]
    fn test_config_serialization() {
        let mut config = Config::new();
        let role = RoleConfig {
            name: "test-role".to_string(),
            role_arn: "arn:aws:iam::123456789012:role/TestRole".to_string(),
            account_id: "123456789012".to_string(),
            source_profile: Some("default".to_string()),
            session_duration: Some(7200),
        };

        config.add_role(role);

        let json = serde_json::to_string(&config).unwrap();
        let deserialized: Config = serde_json::from_str(&json).unwrap();

        assert_eq!(deserialized.roles.len(), 1);
        let role = deserialized.get_role("test-role").unwrap();
        assert_eq!(role.role_arn, "arn:aws:iam::123456789012:role/TestRole");
        assert_eq!(role.source_profile, Some("default".to_string()));
        assert_eq!(role.session_duration, Some(7200));
    }

    #[test]
    fn test_save_and_load_config() {
        let temp_dir = TempDir::new().unwrap();
        let config_dir = temp_dir.path().join(".aws-assume-role");
        fs::create_dir_all(&config_dir).unwrap();

        let mut config = Config::new();
        let role = RoleConfig {
            name: "test-role".to_string(),
            role_arn: "arn:aws:iam::123456789012:role/TestRole".to_string(),
            account_id: "123456789012".to_string(),
            source_profile: None,
            session_duration: Some(3600),
        };

        config.add_role(role);

        // Set appropriate environment variables for cross-platform compatibility
        std::env::set_var("HOME", temp_dir.path());
        #[cfg(windows)]
        std::env::set_var("USERPROFILE", temp_dir.path());

        // Test saving
        let save_result = config.save();
        assert!(save_result.is_ok());

        // Test loading
        let loaded_config = Config::load();
        assert!(loaded_config.is_ok());
        let loaded_config = loaded_config.unwrap();
        assert_eq!(loaded_config.roles.len(), 1);
        assert!(loaded_config.get_role("test-role").is_some());

        // Clean up environment variables
        std::env::remove_var("HOME");
        #[cfg(windows)]
        std::env::remove_var("USERPROFILE");
    }

    #[test]
    fn test_load_nonexistent_config() {
        let temp_dir = TempDir::new().unwrap();

        // Set appropriate environment variables for cross-platform compatibility
        std::env::set_var("HOME", temp_dir.path());
        #[cfg(windows)]
        std::env::set_var("USERPROFILE", temp_dir.path());

        let result = Config::load();
        assert!(result.is_ok());
        let config = result.unwrap();
        assert!(config.roles.is_empty());

        // Clean up environment variables
        std::env::remove_var("HOME");
        #[cfg(windows)]
        std::env::remove_var("USERPROFILE");
    }

    #[test]
    fn test_duplicate_role_names() {
        let mut config = Config::new();

        let role1 = RoleConfig {
            name: "test-role".to_string(),
            role_arn: "arn:aws:iam::123456789012:role/TestRole1".to_string(),
            account_id: "123456789012".to_string(),
            source_profile: None,
            session_duration: Some(3600),
        };

        let role2 = RoleConfig {
            name: "test-role".to_string(), // Same name
            role_arn: "arn:aws:iam::123456789012:role/TestRole2".to_string(),
            account_id: "123456789012".to_string(),
            source_profile: None,
            session_duration: Some(7200),
        };

        config.add_role(role1);
        config.add_role(role2); // Should replace the first one

        assert_eq!(config.roles.len(), 1);
        let role = config.get_role("test-role").unwrap();
        assert_eq!(role.role_arn, "arn:aws:iam::123456789012:role/TestRole2");
        assert_eq!(role.session_duration, Some(7200));
    }

    #[test]
    fn test_config_path() {
        let temp_dir = TempDir::new().unwrap();

        // Set appropriate environment variables for cross-platform compatibility
        std::env::set_var("HOME", temp_dir.path());

        // On Windows, also set USERPROFILE which dirs::home_dir() uses
        #[cfg(windows)]
        std::env::set_var("USERPROFILE", temp_dir.path());

        let path = Config::get_config_path().unwrap();
        let expected = temp_dir.path().join(".aws-assume-role").join("config.json");
        assert_eq!(path, expected);

        // Clean up environment variables
        std::env::remove_var("HOME");
        #[cfg(windows)]
        std::env::remove_var("USERPROFILE");
    }
}
