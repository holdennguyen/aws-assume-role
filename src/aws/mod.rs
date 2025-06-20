use aws_config::SdkConfig;
use aws_sdk_sso::Client as SsoClient;
use aws_sdk_sts::Client as StsClient;
use crate::error::{AppError, AppResult};
use crate::config::RoleConfig;
use std::time::{SystemTime, UNIX_EPOCH};

pub struct AwsClient {
    sts_client: StsClient,
    sso_client: SsoClient,
}

#[derive(Debug)]
pub struct Credentials {
    pub access_key_id: String,
    pub secret_access_key: String,
    pub session_token: Option<String>,
    pub expiration: Option<SystemTime>,
}

impl AwsClient {
    pub async fn new() -> AppResult<Self> {
        let config = aws_config::from_env().load().await;
        Ok(Self::new_with_config(&config))
    }

    pub fn new_with_config(config: &SdkConfig) -> Self {
        let sts_client = StsClient::new(config);
        let sso_client = SsoClient::new(config);

        Self {
            sts_client,
            sso_client,
        }
    }

    pub async fn assume_role(&self, role_config: &RoleConfig, duration_seconds: Option<i32>) -> AppResult<Credentials> {
        let duration = duration_seconds.unwrap_or(3600);
        
        let assume_role_result = self.sts_client
            .assume_role()
            .role_arn(&role_config.role_arn)
            .role_session_name("aws-assume-role-session")
            .duration_seconds(duration)
            .send()
            .await
            .map_err(|e| AppError::AwsError(format!("Failed to assume role: {}", e)))?;

        let credentials = assume_role_result
            .credentials
            .ok_or_else(|| AppError::AwsError("No credentials returned".to_string()))?;

        let expiration = credentials
            .expiration
            .map(|exp| UNIX_EPOCH + std::time::Duration::from_secs(exp.secs().try_into().unwrap_or(0)));

        Ok(Credentials {
            access_key_id: credentials.access_key_id.unwrap_or_default(),
            secret_access_key: credentials.secret_access_key.unwrap_or_default(),
            session_token: credentials.session_token,
            expiration,
        })
    }

    pub async fn get_sso_credentials(&self, account_id: &str, role_name: &str, access_token: &str) -> AppResult<Credentials> {
        let role_creds = self.sso_client
            .get_role_credentials()
            .role_name(role_name)
            .account_id(account_id)
            .access_token(access_token)
            .send()
            .await
            .map_err(|e| AppError::AwsError(format!("Failed to get SSO role credentials: {}", e)))?;

        let role_creds = role_creds
            .role_credentials
            .ok_or_else(|| AppError::AwsError("No SSO credentials returned".to_string()))?;

        Ok(Credentials {
            access_key_id: role_creds.access_key_id.unwrap_or_default(),
            secret_access_key: role_creds.secret_access_key.unwrap_or_default(),
            session_token: role_creds.session_token,
            expiration: Some(UNIX_EPOCH + std::time::Duration::from_secs(
                u64::try_from(role_creds.expiration).unwrap_or(0)
            )),
        })
    }
}
