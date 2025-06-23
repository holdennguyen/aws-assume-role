#!/bin/bash
# AWS Assume Role - Bash Wrapper
#
# This script should be sourced in your shell's profile (e.g., .bashrc, .zshrc)
# to enable the 'awsr' command and manage the PATH.
#
# Example for ~/.bash_profile or ~/.bashrc:
#   source "/path/to/your/install_dir/aws-assume-role-bash.sh"
#

# --- Self-Contained PATH Management ---
# Get the directory where this script is located.
_AWS_ASSUME_ROLE_SCRIPT_DIR="$(cd "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# This function is now the single source of truth for the 'awsr' command.
awsr() {
    # 1. Determine OS and the full binary path
    local os_type
    case "$(uname -s)" in
        Linux*)   os_type="linux" ;;
        Darwin*)  os_type="macos" ;;
        MINGW*|MSYS*|CYGWIN*) os_type="windows" ;;
        *)
            echo "awsr: Unsupported OS: $(uname -s)" >&2
            return 1
            ;;
    esac

    local binary_name="aws-assume-role-$os_type"
    if [ "$os_type" = "windows" ]; then
        binary_name="aws-assume-role-windows.exe"
    fi
    
    # Construct the full, absolute path to the binary.
    # This avoids all PATH-related issues.
    local binary_path="$_AWS_ASSUME_ROLE_SCRIPT_DIR/$binary_name"

    if [ ! -x "$binary_path" ]; then
        echo "awsr: Error: binary not found or not executable at '$binary_path'" >&2
        return 1
    fi

    # 2. Handle the 'assume' command to modify the current shell
    if [ "$1" = "assume" ]; then
        local output
        # Pass all arguments to the binary and request 'export' format.
        # If the command fails, its stderr will be captured in 'output'.
        if output=$("$binary_path" "$@" --format export); then
            # On success, evaluate the output to set environment variables.
            eval "$output"
        else
            # On failure, print the error captured from the binary and return failure.
            echo "$output" >&2
            return 1
        fi
    else
        # 3. For all other commands, execute the binary directly.
        # This passes through args, stdout, stderr, and exit codes correctly.
        "$binary_path" "$@"
    fi
}
