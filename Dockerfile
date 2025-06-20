# AWS Assume Role CLI - Docker Container
FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI (for identity verification)
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

# Create app user
RUN useradd -m -s /bin/bash awsuser

# Copy the binary
COPY target/release/aws-assume-role /usr/local/bin/aws-assume-role
RUN chmod +x /usr/local/bin/aws-assume-role

# Copy wrapper scripts
COPY releases/multi-shell/aws-assume-role-bash.sh /usr/local/bin/awsr
RUN chmod +x /usr/local/bin/awsr

# Switch to non-root user
USER awsuser
WORKDIR /home/awsuser

# Set up shell integration
RUN echo 'source /usr/local/bin/awsr' >> ~/.bashrc

# Default command
CMD ["/bin/bash"]

# Labels for GitHub Container Registry
LABEL org.opencontainers.image.title="AWS Assume Role CLI"
LABEL org.opencontainers.image.description="Simple CLI tool to easily switch between AWS IAM roles"
LABEL org.opencontainers.image.source="https://github.com/holdennguyen/aws-assume-role"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.version="1.0.2" 