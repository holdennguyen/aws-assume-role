# AWS Assume Role - Project Brief

## Project Purpose
The AWS Assume Role project aims to simplify the process of switching between AWS IAM roles in CLI environments for users with SSO federated access. This tool bridges the gap between SSO-based access and IAM role-based permissions, making it easier for users to manage their AWS credentials and role assumptions.

## Core Requirements
1. Simple and Quick Usage
   - Minimal user interaction required
   - Fast role switching capabilities
   - Intuitive command interface

2. Cross-Platform Compatibility
   - Support for MacOS, Linux, and Windows
   - Compatible with bash shell, zshell, and git bash
   - Consistent experience across platforms

3. User-Friendly Experience
   - Clear feedback and error messages
   - Minimal setup requirements
   - Straightforward credential management

## Target Users
Software engineers who:
- Are familiar with coding but not necessarily AWS authentication/authorization
- Work with multiple AWS accounts and roles
- Need to frequently switch between different IAM roles
- Use AWS CLI as part of their daily workflow

## Problem Statement
### Current Challenges
1. Migration from SSO Permission Sets to IAM Roles
   - Users previously had dedicated SSO permission sets in AWS accounts
   - These permissions have been replaced by IAM roles per account
   - Users now need SSO permissions specifically to assume these IAM roles

2. Complex Credential Management
   - Users must manage multiple sets of credentials:
     - aws_access_key_id
     - aws_secret_access_key
     - session tokens
     - AWS profiles

3. Multi-Step Process
   - Users must first obtain short-term SSO credentials
   - Then set up CLI configurations
   - Finally assume specific IAM roles
   - Process needs to be repeated for different accounts/roles

### Solution Goals
1. Streamline the role assumption process
2. Simplify credential management
3. Reduce the number of manual steps required
4. Provide a consistent experience across different shells and operating systems 