# Product Context

## User Journey and Challenges
### Current Workflow
1. SSO Authentication Process
   - Users must first access AWS Console
   - Obtain short-term SSO credentials manually
   - Configure these credentials in their CLI environment

2. Role Assumption Process
   - Users need to identify the correct IAM role for their task
   - Manually assume the role using AWS CLI commands
   - Manage the temporary credentials provided by the role

### Pain Points
1. Manual Credential Management
   - Multiple steps to obtain and configure credentials
   - Need to track different sets of credentials
   - Time-consuming process for frequent role switches

2. Complex Configuration
   - Setting up AWS profiles
   - Managing multiple AWS accounts
   - Handling temporary credential expiration

## Product Requirements

### Core Functionality
1. Credential Output
   - Must provide formatted output for:
     - AWS access key ID
     - AWS secret access key
     - Session token
     - Profile information

2. Cross-Platform Support
   - Must work seamlessly across:
     - bash shell
     - zshell
     - git bash (Windows)
     - MacOS
     - Linux
     - Windows

### User Experience Goals
1. Minimal Setup
   - Reduce configuration requirements
   - Streamline installation process
   - Minimize dependencies

2. Intuitive Usage
   - Clear command structure
   - Helpful error messages
   - Simple role switching process

3. Efficient Workflow
   - Quick role assumption
   - Easy credential access
   - Minimal manual intervention

## Integration Requirements
1. AWS CLI Compatibility
   - Work with existing AWS CLI configurations
   - Support standard AWS credential formats
   - Integrate with AWS SDK workflows

2. Shell Environment Integration
   - Compatible with common shell environments
   - Support for environment variable management
   - Easy integration with existing shell configurations 