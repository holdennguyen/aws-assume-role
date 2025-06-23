#!/bin/bash
# dev-cli.sh
# Unified Developer CLI for the AWS Assume Role project.
# A single entry point for all common development and release tasks.

set -e

# Change to project root directory to ensure scripts run from the correct context
cd "$(dirname "$0")"

# --- Configuration ---
SCRIPTS_DIR="scripts"
PRE_COMMIT_SCRIPT="$SCRIPTS_DIR/pre-commit-hook.sh"
BUILD_SCRIPT="$SCRIPTS_DIR/build-releases.sh"
RELEASE_SCRIPT="$SCRIPTS_DIR/release.sh"

# --- Colors and Logging ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Help Message ---
show_usage() {
    echo -e "${BLUE}AWS Assume Role - Developer CLI${NC}"
    echo "A unified script for all your development needs."
    echo ""
    echo "USAGE:"
    echo "  ./dev-cli.sh <command> [options]"
    echo ""
    echo "COMMANDS:"
    echo "  check          Run all pre-commit quality checks (format, lint, test, build)."
    echo "                 This is the standard check before committing."
    echo ""
    echo "  build          Build cross-platform binaries for Linux, macOS, and Windows."
    echo "                 This is needed to run shell integration tests locally."
    echo ""
    echo "  release [args]   Manage the release process (prepare version, create notes, etc.)."
    echo "                 Pass arguments directly to the underlying release script."
    echo "                 Example: ./dev-cli.sh release prepare 1.4.0"
    echo ""
    echo "  help           Show this help message."
    echo ""
    echo "DEVELOPER WORKFLOW:"
    echo "  1. Make code changes."
    echo "  2. Run './dev-cli.sh check' to ensure quality."
    echo "  3. Commit changes."
    echo "  4. For releases, follow instructions in 'docs/DEVELOPER_WORKFLOW.md'."
}

# --- Main Command Handler ---
main() {
    local command="$1"
    
    if [ -z "$command" ]; then
        show_usage
        exit 1
    fi
    
    # Remove the main command from the argument list
    shift
    
    case "$command" in
        check)
            echo -e "${GREEN}Running pre-commit quality checks...${NC}"
            bash "$PRE_COMMIT_SCRIPT"
            ;;
        
        build)
            echo -e "${GREEN}Building cross-platform release binaries...${NC}"
            bash "$BUILD_SCRIPT"
            ;;
            
        release)
            echo -e "${GREEN}Initiating release process...${NC}"
            if [ ! -f "$RELEASE_SCRIPT" ]; then
                echo "Error: Release script not found at $RELEASE_SCRIPT"
                exit 1
            fi
            bash "$RELEASE_SCRIPT" "$@"
            ;;
            
        help|--help|-h)
            show_usage
            ;;
            
        *)
            echo "Error: Unknown command '$command'"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run the main function with all provided arguments
main "$@" 