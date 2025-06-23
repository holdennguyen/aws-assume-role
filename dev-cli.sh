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
    echo "  build          Build all cross-platform binaries into the 'releases/' directory."
    echo ""
    echo "  package <ver>  Create a local, distributable release package (archives and checksums)."
    echo ""
    echo "  release <ver>  Prepare for a new release (updates version and creates release notes)."
    echo "                 Example: ./dev-cli.sh release 1.4.0"
    echo ""
    echo "  help           Show this help message."
    echo ""
    echo "EXAMPLES:"
    echo "  ./dev-cli.sh check"
    echo "  ./dev-cli.sh build"
    echo "  ./dev-cli.sh package 1.4.0"
    echo "  ./dev-cli.sh release 1.4.0"
    echo ""
    echo "DEVELOPER WORKFLOW:"
    echo "  1. Make your changes"
    echo "  2. Run: ./dev-cli.sh check"
    echo "  3. Commit and push your changes"
    echo "  4. For releases: ./dev-cli.sh release <version>"
    echo ""
}

# --- Main Logic ---
main() {
    local command="$1"
    shift
    
    case "$command" in
        check)
            echo -e "${GREEN}Running quality checks...${NC}"
            bash "$PRE_COMMIT_SCRIPT"
            ;;
            
        build)
            echo -e "${GREEN}Building local artifacts...${NC}"
            bash "$RELEASE_SCRIPT" build
            ;;
            
        package)
            echo -e "${GREEN}Packaging local artifacts for distribution...${NC}"
            bash "$RELEASE_SCRIPT" package "$@"
            ;;
            
        release)
            echo -e "${GREEN}Preparing release...${NC}"
            bash "$RELEASE_SCRIPT" prepare "$@"
            ;;
            
        help|--help|-h)
            show_usage
            ;;
            
        *)
            echo -e "${BLUE}Unknown command: $command${NC}"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# --- Script Execution ---
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 