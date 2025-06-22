# 🔧 Technical Context

Comprehensive technical documentation covering system patterns, technology stack, and implementation details for AWS Assume Role CLI.

## 🏗️ System Patterns & Architecture

### **Core Architecture Pattern**

AWS Assume Role CLI follows a layered architecture pattern with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│           User Interface Layer          │  Shell wrappers, CLI commands
├─────────────────────────────────────────┤
│          Application Layer              │  Command parsing, validation
├─────────────────────────────────────────┤
│           Business Logic Layer          │  AWS operations via SDK, config mgmt
├─────────────────────────────────────────┤
│          Infrastructure Layer           │  File I/O, network requests
└─────────────────────────────────────────┘
```

### **Key Design Patterns**

**1. Cross-Platform Abstraction Pattern**
```rust
// Environment variable handling with fallbacks
pub fn get_config_path() -> PathBuf {
    // Check both HOME (Unix) and USERPROFILE (Windows)
    if let Ok(home) = env::var("HOME") {
        return PathBuf::from(home).join(".aws-assume-role");
    }
    if let Ok(userprofile) = env::var("USERPROFILE") {
        return PathBuf::from(userprofile).join(".aws-assume-role");
    }
    
    // Fallback to dirs crate
    dirs::home_dir()
        .unwrap_or_else(|| PathBuf::from("."))
        .join(".aws-assume-role")
}
```

**2. Command Pattern for CLI Operations**
```rust
#[derive(Subcommand)]
pub enum Commands {
    Assume { role: String, duration: Option<u32> },
    List,
    Configure,
}

impl Commands {
    pub fn execute(&self, config: &Config) -> Result<()> {
        match self {
            Commands::Assume { role, duration } => {
                assume_role_handler(role, *duration, config)
            }
            Commands::List => list_roles_handler(config),
            Commands::Configure => configure_handler(config),
        }
    }
}
```

**3. Error Chain Pattern**
```rust
#[derive(Error, Debug)]
pub enum CliError {
    #[error("AWS CLI not found. Please install AWS CLI v2")]
    AwsCliNotFound,
    
    #[error("Failed to assume role '{role}': {source}")]
    AssumeRoleFailed { 
        role: String, 
        #[source] source: Box<dyn std::error::Error> 
    },
    
    #[error("Configuration error: {0}")]
    ConfigError(String),
    
    #[error("IO error: {source}")]
    IoError { #[from] source: std::io::Error },
}
```

**4. Shell Integration Strategy Pattern**
```bash
# Bash/Zsh wrapper pattern
awsr() {
    local output
    output=$(command awsr "$@" 2>&1)
    local exit_code=$?
    
    if [ $exit_code -eq 0 ] && [[ "$1" == "assume" ]]; then
        eval "$output"  # Apply environment variables
    else
        echo "$output"  # Display output/errors
    fi
    
    return $exit_code
}
```

### **Data Flow Patterns**

**Role Assumption Flow**:
```
User Command → CLI Parser → Config Loader → AWS SDK Client → AWS API Call → Credential Parser → Shell Exporter
```

**Configuration Management Flow**:
```
File Discovery → JSON Parser → Validation → In-Memory Model → Operations → Serialization → File Write
```

**Error Handling Flow**:
```
Low-Level Error → Context Addition → Error Chain → User-Friendly Message → Exit Code
```

## 💻 Technology Stack

### **Core Technologies**

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Language** | Rust | 1.70+ | Performance, safety, cross-platform |
| **CLI Framework** | clap | 4.x | Argument parsing, help generation |
| **Error Handling** | thiserror | 1.x | Structured error types |
| **Serialization** | serde + serde_json | 1.x | Config and AWS response parsing |
| **Cross-Platform** | dirs | 5.x | Platform-specific directories |
| **Testing** | cargo test | Built-in | Unit and integration testing |
| **Shell Testing** | assert_cmd | 2.x | CLI testing framework |

### **Development Tools & Infrastructure**

| Tool | Purpose | Integration |
|------|---------|-------------|
| **rustfmt** | Code formatting | CI enforcement |
| **clippy** | Linting and best practices | Zero warnings policy |
| **cargo-audit** | Security vulnerability scanning | Automated in CI |
| **criterion** | Performance benchmarking | Regression detection |
| **tarpaulin** | Code coverage analysis | Quality metrics |
| **serial_test** | Test isolation | Environment variable tests |

### **Build & Distribution**

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Build System** | Cargo | Rust package management |
| **Cross Compilation** | cargo + targets | Multi-platform binaries |
| **CI/CD** | GitHub Actions | Automated testing and release |
| **Package Hosting** | Multiple registries | Distribution channels |
| **Container** | Docker | Containerized distribution |

### **Package Distribution Channels**

| Channel | Registry | Automation | Status |
|---------|----------|------------|--------|
| **Cargo** | crates.io | ✅ Automated | Active |
| **Homebrew** | holdennguyen/tap | ✅ Automated | Active |
| **Container** | GitHub Container Registry | ✅ Automated | Active |
| **GitHub** | Releases | ✅ Automated | Active |

## 🔧 Implementation Patterns

### **Configuration Management Pattern**

**Layered Configuration Resolution**:
```rust
pub struct ConfigManager {
    default_config: Config,
    file_config: Option<Config>,
    env_config: Config,
    cli_config: Config,
}

impl ConfigManager {
    pub fn resolve(&self) -> Config {
        let mut config = self.default_config.clone();
        
        // Layer 1: File configuration
        if let Some(file_config) = &self.file_config {
            config.merge(file_config);
        }
        
        // Layer 2: Environment variables
        config.merge(&self.env_config);
        
        // Layer 3: CLI arguments (highest priority)
        config.merge(&self.cli_config);
        
        config
    }
}
```

**Atomic Configuration Updates**:
```rust
pub fn save_config(config: &Config) -> Result<()> {
    let config_path = get_config_path();
    let temp_path = config_path.with_extension("tmp");
    
    // Write to temporary file first
    let json = serde_json::to_string_pretty(config)?;
    fs::write(&temp_path, json)?;
    
    // Atomic move to final location
    fs::rename(temp_path, config_path)?;
    
    Ok(())
}
```

### **AWS Integration Pattern (AWS SDK for Rust)**

**STS Client Initialization**:
```rust
async fn get_sts_client(config: &aws_config::SdkConfig) -> aws_sdk_sts::Client {
    aws_sdk_sts::Client::new(config)
}
```

**Assume Role API Call**:
```rust
pub async fn assume_role(
    client: &aws_sdk_sts::Client,
    role_arn: &str,
    session_name: &str,
) -> Result<aws_sdk_sts::model::Credentials, aws_sdk_sts::Error> {
    let response = client
        .assume_role()
        .role_arn(role_arn)
        .role_session_name(session_name)
        .send()
        .await?;

    Ok(response.credentials.unwrap())
}
```

**Response Handling**:
```rust
// The SDK provides strongly-typed structs for responses.
let credentials = assume_role(&client, "arn:...", "session").await?;
println!("Access Key: {}", credentials.access_key_id().unwrap());
```

### **Cross-Platform Testing Pattern**

**Environment Variable Test Isolation**:
```rust
#[cfg(test)]
mod tests {
    use super::*;
    use serial_test::serial;
    use std::env;
    use tempfile::TempDir;

    #[test]
    #[serial]  // Prevent race conditions
    fn test_config_path_cross_platform() {
        // Store original environment
        let original_home = env::var("HOME").ok();
        let original_userprofile = env::var("USERPROFILE").ok();
        
        // Test Unix path
        env::set_var("HOME", "/tmp/test");
        env::remove_var("USERPROFILE");
        assert_eq!(get_config_path(), PathBuf::from("/tmp/test/.aws-assume-role"));
        
        // Test Windows path
        env::remove_var("HOME");
        env::set_var("USERPROFILE", "C:\\Users\\test");
        assert_eq!(get_config_path(), PathBuf::from("C:\\Users\\test\\.aws-assume-role"));
        
        // Restore original environment
        restore_env_vars(original_home, original_userprofile);
    }
    
    fn restore_env_vars(home: Option<String>, userprofile: Option<String>) {
        match home {
            Some(val) => env::set_var("HOME", val),
            None => env::remove_var("HOME"),
        }
        match userprofile {
            Some(val) => env::set_var("USERPROFILE", val),
            None => env::remove_var("USERPROFILE"),
        }
    }
}
```

**Integration Test Pattern**:
```rust
#[test]
fn test_cli_integration() {
    let temp_dir = TempDir::new().unwrap();
    
    let mut cmd = Command::cargo_bin("aws-assume-role").unwrap();
    cmd.env("HOME", temp_dir.path())
       .env("USERPROFILE", temp_dir.path())
       .arg("--help");
    
    cmd.assert()
       .success()
       .stdout(predicate::str::contains("AWS Assume Role CLI"));
}
```

## 🧪 Testing Architecture

### **Test Structure (59 Total Tests)**

```
Testing Framework:
├── Unit Tests (14 tests)
│   ├── config::tests (10 tests)
│   │   ├── Configuration loading/saving
│   │   ├── Cross-platform path handling
│   │   ├── JSON serialization/deserialization
│   │   └── Environment variable resolution
│   └── error::tests (4 tests)
│       ├── Error type creation
│       ├── Error chain handling
│       └── Display formatting
├── Integration Tests (23 tests)
│   ├── CLI functionality testing
│   ├── End-to-end workflows
│   ├── Error scenario validation
│   └── Configuration integration
└── Shell Integration Tests (22 tests)
    ├── Bash/Zsh wrapper validation (6 tests)
    ├── PowerShell wrapper validation (6 tests)
    ├── Fish shell wrapper validation (5 tests)
    └── CMD batch wrapper validation (5 tests)
```

### **Quality Assurance Patterns**

**CI/CD Quality Gates**:
```yaml
# Quality gates enforced in CI
- name: Check formatting
  run: cargo fmt --all -- --check

- name: Run clippy
  run: cargo clippy -- -D warnings

- name: Run tests
  run: cargo test

- name: Security audit
  run: cargo audit
```

**Performance Benchmarking**:
```rust
// benches/performance.rs
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn bench_config_load(c: &mut Criterion) {
    c.bench_function("config_load", |b| {
        b.iter(|| {
            let config = Config::load(black_box("test_config.json"));
            black_box(config)
        })
    });
}

criterion_group!(benches, bench_config_load);
criterion_main!(benches);
```

## 🔒 Security Patterns

### **Secure Credential Handling**

**Memory Safety**:
```rust
// Use secure string types for sensitive data
use secrecy::{Secret, ExposeSecret};

pub struct SecureCredentials {
    access_key: Secret<String>,
    secret_key: Secret<String>,
    session_token: Secret<String>,
}

impl SecureCredentials {
    pub fn to_env_exports(&self) -> String {
        format!(
            "export AWS_ACCESS_KEY_ID='{}'\nexport AWS_SECRET_ACCESS_KEY='{}'\nexport AWS_SESSION_TOKEN='{}'",
            self.access_key.expose_secret(),
            self.secret_key.expose_secret(),
            self.session_token.expose_secret()
        )
    }
}
```

**Input Validation**:
```rust
pub fn validate_role_name(role: &str) -> Result<()> {
    if role.is_empty() {
        return Err(CliError::InvalidInput("Role name cannot be empty".to_string()));
    }
    
    if role.len() > 64 {
        return Err(CliError::InvalidInput("Role name too long".to_string()));
    }
    
    // Validate characters to prevent injection
    if !role.chars().all(|c| c.is_alphanumeric() || c == '-' || c == '_') {
        return Err(CliError::InvalidInput("Invalid characters in role name".to_string()));
    }
    
    Ok(())
}
```

### **Dependency Security**

**Automated Security Auditing**:
```toml
# Cargo.toml - Security-focused dependencies
[dependencies]
clap = { version = "4.0", features = ["derive"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
thiserror = "1.0"
dirs = "5.0"

# Security audit configuration
[audit]
ignore = []  # No ignored vulnerabilities
```

**Regular Security Updates**:
```bash
# Automated security workflow
cargo audit                    # Check for vulnerabilities
cargo update                   # Update dependencies
cargo test                     # Ensure functionality
cargo clippy -- -D warnings   # Check for security issues
```

## 🚀 Performance Patterns

### **Optimization Strategies**

**Lazy Initialization**:
```rust
use std::sync::OnceLock;

static AWS_CLI_PATH: OnceLock<PathBuf> = OnceLock::new();

pub fn get_aws_cli_path() -> &'static PathBuf {
    AWS_CLI_PATH.get_or_init(|| {
        which::which("aws").unwrap_or_else(|_| PathBuf::from("aws"))
    })
}
```

**Efficient JSON Parsing**:
```rust
// Use streaming parser for large responses
pub fn parse_assume_role_response(json: &str) -> Result<Credentials> {
    let response: AssumeRoleResponse = serde_json::from_str(json)
        .map_err(|e| CliError::ParseError(e.to_string()))?;
    Ok(response.credentials)
}
```

**Memory-Efficient String Handling**:
```rust
// Use Cow for efficient string handling
use std::borrow::Cow;

pub fn format_shell_export(key: &str, value: &str) -> Cow<str> {
    if value.contains(' ') || value.contains('\'') {
        Cow::Owned(format!("export {}='{}'", key, value.replace('\'', "'\\''")))
    } else {
        Cow::Owned(format!("export {}={}", key, value))
    }
}
```

## 🔄 Development Workflow Patterns

### **Git Flow Integration**

```
Branch Strategy:
├── master              # Production releases
├── develop             # Integration branch
├── feature/*           # Feature development
├── release/*           # Release preparation
└── hotfix/*           # Critical fixes
```

### **Code Quality Enforcement**

**Pre-commit Workflow**:
```bash
#!/bin/bash
# Pre-commit quality checks

echo "🔍 Running pre-commit checks..."

# Format check
echo "📝 Checking formatting..."
cargo fmt --all -- --check || {
    echo "❌ Code formatting issues found. Run 'cargo fmt' to fix."
    exit 1
}

# Clippy check
echo "🔍 Running clippy..."
cargo clippy -- -D warnings || {
    echo "❌ Clippy warnings found. Please fix all warnings."
    exit 1
}

# Test suite
echo "🧪 Running tests..."
cargo test || {
    echo "❌ Tests failed. Please fix failing tests."
    exit 1
}

# Security audit
echo "🔒 Running security audit..."
cargo audit || {
    echo "❌ Security vulnerabilities found. Please address them."
    exit 1
}

echo "✅ All pre-commit checks passed!"
```

### **Release Automation Pattern**

**Version Management**:
```bash
#!/bin/bash
# scripts/release.sh (unified release management)

NEW_VERSION=$1

# Update Cargo.toml
sed -i "s/version = \".*\"/version = \"$NEW_VERSION\"/" Cargo.toml

# Update package configurations
sed -i "s/version: .*/version: $NEW_VERSION/" packaging/homebrew/aws-assume-role.rb
sed -i "s/Version: .*/Version: $NEW_VERSION/" packaging/rpm/aws-assume-role.spec

# Update documentation
sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+/v$NEW_VERSION/g" README.md

echo "Version updated to $NEW_VERSION"
```

This technical context provides comprehensive coverage of the implementation patterns, technology choices, and development practices that make AWS Assume Role CLI a robust, maintainable, and secure tool. 