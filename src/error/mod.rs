use std::error::Error;
use std::fmt;

#[derive(Debug)]
#[allow(clippy::enum_variant_names)]
pub enum AppError {
    AwsError(String),
    ConfigError(String),
    CliError(String),
    IoError(std::io::Error),
}

impl fmt::Display for AppError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            AppError::AwsError(msg) => write!(f, "{}", msg),
            AppError::ConfigError(msg) => write!(f, "{}", msg),
            AppError::CliError(msg) => write!(f, "{}", msg),
            AppError::IoError(e) => write!(f, "{}", e),
        }
    }
}

impl Error for AppError {
    fn source(&self) -> Option<&(dyn Error + 'static)> {
        match self {
            AppError::IoError(e) => Some(e),
            _ => None,
        }
    }
}

impl From<std::io::Error> for AppError {
    fn from(err: std::io::Error) -> Self {
        AppError::IoError(err)
    }
}

pub type AppResult<T> = Result<T, AppError>;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_cli_error_creation() {
        let error = AppError::CliError("Test CLI error".to_string());
        assert!(matches!(error, AppError::CliError(_)));

        let error_string = error.to_string();
        assert!(error_string.contains("Test CLI error"));
    }

    #[test]
    fn test_aws_error_creation() {
        let error = AppError::AwsError("Test AWS error".to_string());
        assert!(matches!(error, AppError::AwsError(_)));

        let error_string = error.to_string();
        assert!(error_string.contains("Test AWS error"));
    }

    #[test]
    fn test_config_error_creation() {
        let error = AppError::ConfigError("Test config error".to_string());
        assert!(matches!(error, AppError::ConfigError(_)));

        let error_string = error.to_string();
        assert!(error_string.contains("Test config error"));
    }

    #[test]
    fn test_io_error_creation() {
        let io_error = std::io::Error::new(std::io::ErrorKind::NotFound, "File not found");
        let error = AppError::IoError(io_error);
        assert!(matches!(error, AppError::IoError(_)));

        let error_string = error.to_string();
        assert!(error_string.contains("File not found"));
    }

    #[test]
    fn test_config_error_with_json() {
        let json_error = serde_json::from_str::<serde_json::Value>("invalid json").unwrap_err();
        let error = AppError::ConfigError(format!("JSON parsing error: {}", json_error));
        assert!(matches!(error, AppError::ConfigError(_)));
    }

    #[test]
    fn test_error_from_io() {
        let io_error =
            std::io::Error::new(std::io::ErrorKind::PermissionDenied, "Permission denied");
        let app_error: AppError = io_error.into();
        assert!(matches!(app_error, AppError::IoError(_)));
    }

    #[test]
    fn test_error_conversion() {
        let json_error = serde_json::from_str::<serde_json::Value>("invalid json").unwrap_err();
        let error_msg = format!("JSON parsing error: {}", json_error);
        let app_error = AppError::ConfigError(error_msg);
        assert!(matches!(app_error, AppError::ConfigError(_)));
    }

    #[test]
    fn test_error_display() {
        let cli_error = AppError::CliError("CLI error message".to_string());
        let display = format!("{}", cli_error);
        assert_eq!(display, "CLI error message");

        let aws_error = AppError::AwsError("AWS error message".to_string());
        let display = format!("{}", aws_error);
        assert_eq!(display, "AWS error message");

        let config_error = AppError::ConfigError("Config error message".to_string());
        let display = format!("{}", config_error);
        assert_eq!(display, "Config error message");
    }

    #[test]
    fn test_error_debug() {
        let error = AppError::CliError("Debug test".to_string());
        let debug_output = format!("{:?}", error);
        assert!(debug_output.contains("CliError"));
        assert!(debug_output.contains("Debug test"));
    }

    #[test]
    fn test_app_result_ok() {
        let success_value = "Success".to_string();
        let result: AppResult<String> = Ok(success_value.clone());
        assert!(result.is_ok());
        if let Ok(value) = result {
            assert_eq!(value, success_value);
        }
    }

    #[test]
    fn test_app_result_err() {
        let result: AppResult<String> = Err(AppError::CliError("Error".to_string()));
        assert!(result.is_err());

        match result {
            Err(AppError::CliError(msg)) => assert_eq!(msg, "Error"),
            _ => panic!("Expected CliError"),
        }
    }

    #[test]
    fn test_error_chain() {
        let io_error = std::io::Error::new(std::io::ErrorKind::NotFound, "File not found");
        let app_error = AppError::IoError(io_error);

        // Test that we can access the source error
        let error_msg = format!("{}", app_error);
        assert!(error_msg.contains("File not found"));
    }

    #[test]
    fn test_multiple_error_types() {
        let errors = vec![
            AppError::CliError("CLI".to_string()),
            AppError::AwsError("AWS".to_string()),
            AppError::ConfigError("Config".to_string()),
        ];

        for error in errors {
            let _display = format!("{}", error);
            let _debug = format!("{:?}", error);
            // Just ensure they don't panic
        }
    }
}
