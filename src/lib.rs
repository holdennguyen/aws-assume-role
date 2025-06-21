//! AWS Assume Role Library
//! 
//! This library provides functionality for managing and assuming AWS IAM roles
//! across different accounts with SSO federated access.

pub mod aws;
pub mod cli;
pub mod config;
pub mod error;

pub use config::{Config, RoleConfig};
pub use error::{AppError, AppResult}; 