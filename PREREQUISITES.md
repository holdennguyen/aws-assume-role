# 📋 AWS Assume Role CLI - Prerequisites Guide

This guide helps you set up all prerequisites for using AWS Assume Role CLI successfully.

## 🎯 Quick Verification

Before starting, run the built-in verification:
```bash
awsr verify
```

This will check all prerequisites automatically and provide specific guidance for any issues.

## 1. 🛠️ AWS CLI Installation

### Install AWS CLI v2

**macOS (Homebrew)**:
```bash
brew install awscli
```

**macOS/Linux (Official)**:
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Windows**:
Download and run the MSI installer from [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

### Verify Installation
```bash
aws --version
# Should output: aws-cli/2.x.x Python/3.x.x ...
```

## 2. 🔐 AWS Credentials Configuration

You need valid AWS credentials that can assume roles. Here are the common methods:

### Method 1: Access Keys (Basic)
```bash
aws configure
```
Enter your:
- AWS Access Key ID
- AWS Secret Access Key  
- Default region (e.g., us-east-1)
- Output format (json recommended)

### Method 2: AWS SSO (Recommended for Organizations)
```bash
aws configure sso
```
Follow the prompts to set up SSO authentication.

### Method 3: IAM Roles (EC2/ECS/Lambda)
If running on AWS services, use IAM roles attached to the service.

### Method 4: AWS Profiles
Configure multiple profiles in `~/.aws/credentials`:
```ini
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY

[my-profile]
aws_access_key_id = ANOTHER_ACCESS_KEY
aws_secret_access_key = ANOTHER_SECRET_KEY
```

### Verify Credentials
```bash
aws sts get-caller-identity
```
Should return your current AWS identity (Account, Arn, UserId).

## 3. 🔑 IAM Permissions Setup

### Your Current Identity Needs Permission

Your current AWS identity (user/role) must have permission to assume roles:

**Example Policy** (attach to your user/role):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "arn:aws:iam::123456789012:role/DevRole",
        "arn:aws:iam::987654321098:role/ProdRole",
        "arn:aws:iam::*:role/MyRolePattern*"
      ]
    }
  ]
}
```

### Create the Policy
1. Go to AWS IAM Console → Policies → Create Policy
2. Use JSON editor and paste the policy above
3. Adjust the `Resource` ARNs to match your target roles
4. Name it something like "AssumeRolePermissions"
5. Attach it to your user or role

## 4. 🎭 Target Role Trust Policies

Each role you want to assume must trust your current identity.

### Example Trust Policy for Target Role
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::YOUR-ACCOUNT:user/your-username",
          "arn:aws:iam::YOUR-ACCOUNT:role/your-role"
        ]
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "optional-external-id"
        }
      }
    }
  ]
}
```

### Update Trust Policy
1. Go to AWS IAM Console → Roles → Select your target role
2. Go to "Trust relationships" tab
3. Click "Edit trust policy"
4. Update the JSON to include your identity in the Principal
5. Save changes

## 5. 🧪 Testing Your Setup

### Step-by-Step Verification

1. **Test AWS CLI**:
   ```bash
   aws --version
   aws sts get-caller-identity
   ```

2. **Test Role Assumption (Manual)**:
   ```bash
   aws sts assume-role \
     --role-arn arn:aws:iam::123456789012:role/YourRole \
     --role-session-name test-session
   ```

3. **Use AWS Assume Role CLI**:
   ```bash
   # Run comprehensive verification
   awsr verify
   
   # Configure a role
   awsr configure --name test --role-arn arn:aws:iam::123456789012:role/YourRole --account-id 123456789012
   
   # Test assumption
   awsr assume test
   ```

## 🚨 Common Issues and Solutions

### ❌ "AWS CLI not found"
- **Solution**: Install AWS CLI v2 (see section 1)
- **Verify**: `aws --version`

### ❌ "Unable to locate credentials"
- **Solution**: Configure AWS credentials (see section 2)
- **Verify**: `aws sts get-caller-identity`

### ❌ "Access Denied" when assuming role
- **Cause**: Missing sts:AssumeRole permission
- **Solution**: Add IAM policy to your user/role (see section 3)

### ❌ "Not authorized to perform: sts:AssumeRole"
- **Cause**: Target role doesn't trust your identity
- **Solution**: Update target role's trust policy (see section 4)

### ❌ "Role session name is invalid"
- **Cause**: Role session name contains invalid characters
- **Solution**: This is handled automatically by the CLI

### ❌ "Token has expired"
- **Cause**: Temporary credentials have expired
- **Solution**: Refresh your credentials (re-run `aws configure` or SSO login)

## 📚 Additional Resources

### AWS Documentation
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- [IAM Roles and Policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html)
- [STS AssumeRole](https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html)

### AWS Assume Role CLI
- [Main Documentation](README.md)
- [Deployment Guide](DEPLOYMENT.md)
- [GitHub Packages](GITHUB_PACKAGES.md)

## 🎉 Success Checklist

- [ ] AWS CLI v2 installed and working
- [ ] AWS credentials configured and valid
- [ ] Current identity has sts:AssumeRole permission
- [ ] Target roles trust your current identity
- [ ] `awsr verify` passes all checks
- [ ] Successfully configured and assumed a test role

Once all items are checked, you're ready to use AWS Assume Role CLI effectively!

---

**Need help?** Run `awsr verify` for automated troubleshooting or open an issue on GitHub. 