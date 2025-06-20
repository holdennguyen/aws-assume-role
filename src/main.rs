mod aws;
mod cli;
mod config;
mod error;

use error::AppResult;

#[tokio::main]
async fn main() -> AppResult<()> {
    // Initialize logging
    tracing_subscriber::fmt::init();

    // Run the CLI
    cli::Cli::run().await
}
