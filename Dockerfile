# AWS Assume Role CLI - Multi-platform Container
FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI (for identity verification)
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

# Create app user
RUN useradd -m -s /bin/bash awsuser

# Copy the Linux binary (built by CI/CD)
COPY releases/aws-assume-role-linux /usr/local/bin/aws-assume-role
RUN chmod +x /usr/local/bin/aws-assume-role

# Create awsr alias
RUN ln -s /usr/local/bin/aws-assume-role /usr/local/bin/awsr

# Switch to non-root user
USER awsuser
WORKDIR /home/awsuser

# Default command
CMD ["/bin/bash"]

# Labels for GitHub Container Registry
LABEL org.opencontainers.image.title="AWS Assume Role CLI"
LABEL org.opencontainers.image.description="A simple command-line tool to easily switch between AWS IAM roles."
LABEL org.opencontainers.image.source="https://github.com/holdennguyen/aws-assume-role"
LABEL org.opencontainers.image.licenses="AGPL-3.0-or-later" 