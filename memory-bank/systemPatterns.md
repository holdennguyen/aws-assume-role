# System Patterns

## Architecture Overview
AWS Assume Role follows a modular Rust architecture with clear separation of concerns.

### Core Modules
```
src/
├── cli/        # Command parsing and user interface
├── aws/        # AWS SDK integration and role operations  
├── config/     # Configuration management and persistence
├── error/      # Error handling and user messaging
└── main.rs     # Application entry point
```

### Design Patterns

#### Command Pattern
- Structured command handling with clap derive macros
- Clear command-to-function mapping
- Extensible architecture for future commands

#### Configuration Strategy
- JSON-based persistent storage in user home directory
- CRUD operations for role management
- Validation and error recovery

#### Error Handling Strategy
- Comprehensive error types with context
- User-friendly error messages with troubleshooting guidance
- Graceful degradation and recovery suggestions

## Data Flow
```
User Input → CLI Parser → Command Handler → AWS SDK → Credential Output
     ↓
Configuration Storage ← Role Management ← AWS Integration
```

### Key Implementation Decisions

#### AWS SDK Integration
- Uses aws-sdk-sts for role assumption
- Handles temporary credentials and session tokens
- Automatic region detection with us-east-1 fallback

#### Configuration Management
- JSON format for human readability and debugging
- Stored in `~/.aws-assume-role/config.json`
- Atomic write operations for data consistency

#### Cross-Platform Support
- Single binary per platform (no runtime dependencies)
- Platform-specific binary distribution
- Shell wrapper scripts for enhanced integration

#### Error Categories
- **Authentication**: AWS credential and permission issues
- **Configuration**: Role setup and validation problems  
- **Network**: AWS API connectivity issues
- **System**: File I/O and environment problems

## Performance Characteristics
- **Fast Startup**: Minimal initialization overhead
- **Efficient AWS Calls**: Direct STS operations without unnecessary requests
- **Low Memory**: Single-threaded design with minimal allocations
- **Quick Response**: Sub-second role switching

## Testing Strategy
- **Unit Tests**: Per-module functionality testing
- **Integration Tests**: End-to-end command workflows
- **Cross-Platform**: Automated testing on multiple OS/shell combinations
- **AWS Mocking**: Isolated testing without real AWS calls

## Security Patterns
- **Credential Handling**: No persistent storage of AWS credentials
- **Temporary Tokens**: Proper session token management
- **Permissions**: Minimal required AWS permissions
- **Error Privacy**: No credential leakage in error messages 