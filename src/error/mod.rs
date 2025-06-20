use std::error::Error;
use std::fmt;

#[derive(Debug)]
pub enum AppError {
    AwsError(String),
    ConfigError(String),
    CliError(String),
    IoError(std::io::Error),
}

impl fmt::Display for AppError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            AppError::AwsError(msg) => write!(f, "AWS Error: {}", msg),
            AppError::ConfigError(msg) => write!(f, "Configuration Error: {}", msg),
            AppError::CliError(msg) => write!(f, "CLI Error: {}", msg),
            AppError::IoError(e) => write!(f, "IO Error: {}", e),
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
