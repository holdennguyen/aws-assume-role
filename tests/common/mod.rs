use tempfile::TempDir;
use std::fs;
use aws_assume_role::config::{Config, RoleConfig};

/// Test utilities and helper functions for AWS Assume Role testing
pub struct TestHelper {
    pub temp_dir: TempDir,
    pub config_dir: std::path::PathBuf,
}

impl TestHelper {
    /// Create a new test helper with isolated temporary directory
    pub fn new() -> Self {
        let temp_dir = TempDir::new().expect("Failed to create temp directory");
        let config_dir = temp_dir.path().join(".aws-assume-role");
        fs::create_dir_all(&config_dir).expect("Failed to create config directory");
        
        // Set HOME environment variable for isolated testing
        std::env::set_var("HOME", temp_dir.path());
        
        Self {
            temp_dir,
            config_dir,
        }
    }

    /// Create a sample role configuration for testing
    pub fn create_sample_role(name: &str) -> RoleConfig {
        RoleConfig {
            name: name.to_string(),
            role_arn: format!("arn:aws:iam::123456789012:role/{}", name),
            account_id: "123456789012".to_string(),
            source_profile: None,
            session_duration: Some(3600),
        }
    }

    /// Create a sample role configuration with custom parameters
    pub fn create_custom_role(
        name: &str, 
        account_id: &str, 
        role_name: &str,
        duration: Option<i64>
    ) -> RoleConfig {
        RoleConfig {
            name: name.to_string(),
            role_arn: format!("arn:aws:iam::{}:role/{}", account_id, role_name),
            account_id: account_id.to_string(),
            source_profile: None,
            session_duration: duration,
        }
    }

    /// Create a config with multiple sample roles
    pub fn create_sample_config(&self) -> Config {
        let mut config = Config::new();
        
        let roles = vec![
            Self::create_sample_role("dev"),
            Self::create_sample_role("staging"),
            Self::create_sample_role("prod"),
            Self::create_custom_role("test", "987654321098", "TestRole", Some(7200)),
        ];

        for role in roles {
            config.add_role(role);
        }

        config
    }

    /// Save a config to the test directory
    pub fn save_config(&self, config: &Config) -> Result<(), Box<dyn std::error::Error>> {
        config.save().map_err(|e| e.into())
    }

    /// Load config from test directory
    pub fn load_config(&self) -> Result<Config, Box<dyn std::error::Error>> {
        Config::load().map_err(|e| e.into())
    }

    /// Get the config file path
    pub fn config_path(&self) -> std::path::PathBuf {
        self.config_dir.join("config.json")
    }

    /// Check if config file exists
    pub fn config_exists(&self) -> bool {
        self.config_path().exists()
    }

    /// Remove config file if it exists
    pub fn cleanup_config(&self) -> Result<(), std::io::Error> {
        let config_path = self.config_path();
        if config_path.exists() {
            fs::remove_file(config_path)?;
        }
        Ok(())
    }

    /// Create a config with invalid data for error testing
    pub fn create_invalid_config_file(&self) -> Result<(), std::io::Error> {
        let config_path = self.config_path();
        fs::write(config_path, "{ invalid json }")?;
        Ok(())
    }

    /// Create a config file with permissions issues (Unix only)
    #[cfg(unix)]
    pub fn create_readonly_config(&self, config: &Config) -> Result<(), Box<dyn std::error::Error>> {
        use std::os::unix::fs::PermissionsExt;
        
        self.save_config(config)?;
        let config_path = self.config_path();
        let mut perms = fs::metadata(&config_path)?.permissions();
        perms.set_mode(0o444); // Read-only
        fs::set_permissions(&config_path, perms)?;
        Ok(())
    }

    /// Restore write permissions (Unix only)
    #[cfg(unix)]
    pub fn restore_config_permissions(&self) -> Result<(), std::io::Error> {
        use std::os::unix::fs::PermissionsExt;
        
        let config_path = self.config_path();
        if config_path.exists() {
            let mut perms = fs::metadata(&config_path)?.permissions();
            perms.set_mode(0o644); // Read-write
            fs::set_permissions(&config_path, perms)?;
        }
        Ok(())
    }
}

impl Drop for TestHelper {
    fn drop(&mut self) {
        // Ensure cleanup on drop
        #[cfg(unix)]
        let _ = self.restore_config_permissions();
        let _ = self.cleanup_config();
    }
}

/// Mock AWS credentials for testing
pub struct MockCredentials {
    pub access_key_id: String,
    pub secret_access_key: String,
    pub session_token: Option<String>,
}

impl MockCredentials {
    pub fn new() -> Self {
        Self {
            access_key_id: "AKIAIOSFODNN7EXAMPLE".to_string(),
            secret_access_key: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY".to_string(),
            session_token: Some("FQoDYXdzEPT//////////wEaDK...".to_string()),
        }
    }

    pub fn with_session_token(mut self, token: Option<String>) -> Self {
        self.session_token = token;
        self
    }
}

/// Test data constants
pub mod test_data {
    pub const VALID_ROLE_ARN: &str = "arn:aws:iam::123456789012:role/TestRole";
    pub const INVALID_ROLE_ARN: &str = "invalid-arn";
    pub const VALID_ACCOUNT_ID: &str = "123456789012";
    pub const INVALID_ACCOUNT_ID: &str = "invalid-id";
    pub const TEST_ROLE_NAME: &str = "test-role";
    
    pub const SAMPLE_CONFIG_JSON: &str = r#"{
        "roles": [
            {
                "name": "dev",
                "role_arn": "arn:aws:iam::123456789012:role/DevRole",
                "account_id": "123456789012",
                "source_profile": null,
                "session_duration": 3600
            }
        ]
    }"#;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_helper_creation() {
        let helper = TestHelper::new();
        assert!(helper.temp_dir.path().exists());
        assert!(helper.config_dir.exists());
    }

    #[test]
    fn test_sample_role_creation() {
        let role = TestHelper::create_sample_role("test");
        assert_eq!(role.name, "test");
        assert_eq!(role.role_arn, "arn:aws:iam::123456789012:role/test");
        assert_eq!(role.account_id, "123456789012");
    }

    #[test]
    fn test_custom_role_creation() {
        let role = TestHelper::create_custom_role("custom", "987654321098", "CustomRole", Some(7200));
        assert_eq!(role.name, "custom");
        assert_eq!(role.role_arn, "arn:aws:iam::987654321098:role/CustomRole");
        assert_eq!(role.account_id, "987654321098");
        assert_eq!(role.session_duration, Some(7200));
    }

    #[test]
    fn test_sample_config_creation() {
        let helper = TestHelper::new();
        let config = helper.create_sample_config();
        assert_eq!(config.roles.len(), 4);
        assert!(config.get_role("dev").is_some());
        assert!(config.get_role("staging").is_some());
        assert!(config.get_role("prod").is_some());
        assert!(config.get_role("test").is_some());
    }

    #[test]
    fn test_mock_credentials() {
        let creds = MockCredentials::new();
        assert_eq!(creds.access_key_id, "AKIAIOSFODNN7EXAMPLE");
        assert!(creds.session_token.is_some());
        
        let creds_no_token = MockCredentials::new().with_session_token(None);
        assert!(creds_no_token.session_token.is_none());
    }
} 