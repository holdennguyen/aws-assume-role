# Product Context

## Problem Solved
AWS users with SSO federated access need to frequently assume different IAM roles across multiple accounts. The traditional process involves:
1. Manual SSO authentication in web browser
2. Copying temporary credentials 
3. Setting environment variables or AWS profiles
4. Repeating for each role switch

**AWS Assume Role eliminates this friction** with a single command interface.

## Solution Value
- **Time Savings**: Role switching from 2-3 minutes to 5 seconds
- **Error Reduction**: No manual credential copying or environment setup
- **Consistency**: Same experience across all platforms and shells
- **Reliability**: Built-in verification and troubleshooting

## User Experience
### Before AWS Assume Role
```bash
# Manual process (2-3 minutes)
1. Open AWS Console in browser
2. Navigate to SSO portal
3. Click on account/role
4. Copy credentials from console
5. Set environment variables manually
6. Repeat for each role switch
```

### After AWS Assume Role
```bash
# Automated process (5 seconds)  
awsr assume my-prod-role
eval $(awsr assume my-prod-role)
# Ready to use AWS CLI with new role!
```

## Core Features
- **Simple Commands**: `configure`, `assume`, `list`, `verify`, `remove`
- **Multiple Output Formats**: Shell export (default) and JSON
- **Prerequisites Verification**: Built-in system checks and troubleshooting
- **Persistent Configuration**: One-time role setup, reuse forever
- **Cross-Platform**: Works on macOS, Linux, Windows with all major shells

## Target Audience
**Primary**: Software engineers and DevOps professionals who:
- Work with multiple AWS accounts
- Switch between IAM roles frequently  
- Use CLI tools for AWS automation
- Have SSO federated access to AWS

**Secondary**: AWS administrators managing role access patterns

## Integration Points
- **AWS CLI**: Compatible with existing AWS CLI workflows
- **Shell Integration**: Works with bash, zsh, PowerShell, Fish
- **CI/CD Systems**: JSON output format for automated environments
- **Container Environments**: Docker image available

## Success Metrics
- **Installation Growth**: 4 major package managers (Cargo, Homebrew, APT, YUM)
- **User Adoption**: Simplified installation reduces setup friction
- **Support Reduction**: Built-in `verify` command reduces support requests
- **Cross-Platform Reach**: Single solution works everywhere

## Competitive Advantages
1. **Prerequisites Verification**: Only tool with built-in system checks
2. **Universal Compatibility**: Works across all major platforms/shells
3. **Zero Dependencies**: Single binary with no runtime requirements
4. **Professional Distribution**: Available through established package managers
5. **User-Friendly**: Clear error messages and troubleshooting guidance 