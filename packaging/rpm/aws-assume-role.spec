Name:           aws-assume-role
Version:        1.0.0
Release:        1%{?dist}
Summary:        Simple CLI tool to easily switch between AWS IAM roles

License:        MIT
URL:            https://github.com/holdennguyen/aws-assume-role
Source0:        https://github.com/holdennguyen/aws-assume-role/releases/download/v%{version}/aws-assume-role-linux-x86_64

BuildArch:      x86_64
Requires:       awscli >= 2.0.0

%description
AWS Assume Role CLI is a simple command-line tool designed for SSO users
who need to easily switch between AWS IAM roles across different accounts.

Features:
- Easy role switching between AWS accounts
- SSO credential management
- Multiple output formats (shell exports, JSON)
- Persistent role configuration
- Session duration control

The tool automatically sets AWS credentials in your current shell environment,
making it easy to work with different AWS accounts without complex eval commands.

%prep
# No prep needed for binary distribution

%build
# No build needed for binary distribution

%install
rm -rf $RPM_BUILD_ROOT

# Create directories
mkdir -p $RPM_BUILD_ROOT%{_bindir}
mkdir -p $RPM_BUILD_ROOT%{_datadir}/aws-assume-role

# Install binary
install -m 755 %{SOURCE0} $RPM_BUILD_ROOT%{_bindir}/aws-assume-role

# Create wrapper script
cat > $RPM_BUILD_ROOT%{_bindir}/awsr << 'EOF'
#!/bin/bash
# AWS Assume Role CLI wrapper for shell integration

case "$1" in
    assume)
        if [ -z "$2" ]; then
            echo "Usage: awsr assume <role-name>"
            exit 1
        fi
        
        # Get credentials and export them
        eval $(aws-assume-role assume "$2" --format export)
        
        if [ $? -eq 0 ]; then
            echo "✅ Successfully assumed role: $2"
            echo "🔍 Current AWS identity:"
            aws sts get-caller-identity --output table 2>/dev/null || echo "Run 'aws sts get-caller-identity' to verify"
        else
            echo "❌ Failed to assume role: $2"
            exit 1
        fi
        ;;
    *)
        # Pass through all other commands
        aws-assume-role "$@"
        ;;
esac
EOF

chmod +x $RPM_BUILD_ROOT%{_bindir}/awsr

# Create helper functions script
cat > $RPM_BUILD_ROOT%{_datadir}/aws-assume-role/shell-helpers.sh << 'EOF'
#!/bin/bash
# AWS Assume Role CLI shell helper functions

# Clear AWS credentials from current shell
clear_aws_creds() {
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    echo "🧹 AWS credentials cleared from current shell"
}

# Show current AWS identity
aws_whoami() {
    if command -v aws >/dev/null 2>&1; then
        aws sts get-caller-identity --output table 2>/dev/null || echo "❌ No AWS credentials found"
    else
        echo "❌ AWS CLI not found"
    fi
}

# Export functions
export -f clear_aws_creds aws_whoami
EOF

chmod +x $RPM_BUILD_ROOT%{_datadir}/aws-assume-role/shell-helpers.sh

%files
%{_bindir}/aws-assume-role
%{_bindir}/awsr
%{_datadir}/aws-assume-role/shell-helpers.sh

%post
echo ""
echo "AWS Assume Role CLI has been installed!"
echo ""
echo "Usage:"
echo "  awsr configure --name dev --role-arn arn:aws:iam::123:role/DevRole --account-id 123"
echo "  awsr assume dev"
echo "  awsr list"
echo ""
echo "For shell helper functions, add this to your ~/.bashrc or ~/.zshrc:"
echo "  source %{_datadir}/aws-assume-role/shell-helpers.sh"
echo ""

%preun
if [ $1 -eq 0 ]; then
    echo "AWS Assume Role CLI is being removed!"
    echo "Note: Your role configurations in ~/.aws-assume-role/ are preserved."
fi

%changelog
* Thu Jun 20 2025 Hung, Nguyen Minh <holdennguyen6174@gmail.com> - 1.0.0-1
- Initial RPM package release