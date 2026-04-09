#!/usr/bin/env bash
#
# Bash wrapper for ZeroTrustAssessment PowerShell module
#
# Author: Microsoft
#
# Description:
#   Cross-platform entry point for running ZeroTrustAssessment commands from
#   source on Linux and macOS. Ensures PowerShell 7+ is installed and functional,
#   resolves module dependencies, and executes the specified command.
#
# Features:
#   - Detects whether PowerShell (pwsh) is installed on the system.
#   - Installs or upgrades PowerShell via apt-get, yum, Homebrew, or GitHub
#     release tarball. Validates the configured version exists before attempting.
#   - Verifies pwsh is on PATH and functional before handing off.
#   - Dynamically queries the module for available commands and help text,
#     so the wrapper stays in sync when exported functions change.
#   - Validates the user's command against the module's exported functions.
#   - Supports unattended install/upgrade via the AUTO_INSTALL_PWSH flag.
#   - Delegates all module logic (dependency resolution, container detection,
#     authentication, assessment) to the PowerShell module itself.
#
# Configuration:
#   POWERSHELL_VERSION    - Required PowerShell version (default: 7.5.1).
#   AUTO_INSTALL_PWSH     - Set to "true" to install/upgrade without prompting.
#                           Defaults to "false" (always ask).
#
# Usage:
#   ./ZeroTrustAssessment.sh <command> [args...]
#
# Examples:
#   ./ZeroTrustAssessment.sh Connect-ZtAssessment                 # Connect to services
#   ./ZeroTrustAssessment.sh Connect-ZtAssessment -UseDeviceCode  # Device code auth
#   ./ZeroTrustAssessment.sh Invoke-ZtAssessment                  # Run the assessment
#   ./ZeroTrustAssessment.sh Get-ZtTest                           # List available tests
#   ./ZeroTrustAssessment.sh Get-ZtTestStatistics                 # Show test statistics
#   ./ZeroTrustAssessment.sh Disconnect-ZtAssessment              # Disconnect services
#   ./ZeroTrustAssessment.sh Get-Help Connect-ZtAssessment -Full  # Detailed help
#

set -euo pipefail

# --- Configuration ---
: "${POWERSHELL_VERSION:=7.5.1}"
: "${AUTO_INSTALL_PWSH:=false}"  # "true" = install/upgrade without prompting
# ----------------------

# --- Paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="${SCRIPT_DIR}/src/powershell"

# --- State ---
_MODULE_COMMANDS=""  # cached output from ensure_module_commands

# --- Functions ---

# Validates that POWERSHELL_VERSION corresponds to a real GitHub release.
verify_powershell_version() {
  echo "Verifying PowerShell version ${POWERSHELL_VERSION} exists..."
  local url="https://github.com/PowerShell/PowerShell/releases/tag/v${POWERSHELL_VERSION}"
  if ! curl -fsSL --head "$url" &>/dev/null; then
    echo "Error: PowerShell version ${POWERSHELL_VERSION} does not exist." >&2
    echo "Set POWERSHELL_VERSION to a valid release in this script." >&2
    echo "Available versions: https://github.com/PowerShell/PowerShell/releases" >&2
    exit 1
  fi
}

# Installs PowerShell using the best available package manager.
# Package-manager installs use the repository/tap's current version.
# The GitHub release tarball fallback installs the exact POWERSHELL_VERSION.
install_powershell() {
  verify_powershell_version
  echo "Preparing to install PowerShell."
  echo "Requested exact version: ${POWERSHELL_VERSION}"
  if command -v apt-get &>/dev/null; then
    echo "  Using apt-get (Debian/Ubuntu) to install the repository's current PowerShell version."
    echo "  Note: apt-get may not install exactly ${POWERSHELL_VERSION}."
    source /etc/os-release
    if command -v wget &>/dev/null; then
      wget -q "https://packages.microsoft.com/config/${ID}/${VERSION_ID}/packages-microsoft-prod.deb" -O /tmp/packages-microsoft-prod.deb
    elif command -v curl &>/dev/null; then
      curl -fsSL "https://packages.microsoft.com/config/${ID}/${VERSION_ID}/packages-microsoft-prod.deb" -o /tmp/packages-microsoft-prod.deb
    else
      echo "Error: apt-get install flow requires either wget or curl to download Microsoft's package repository configuration." >&2
      exit 1
    fi
    sudo dpkg -i /tmp/packages-microsoft-prod.deb && rm -f /tmp/packages-microsoft-prod.deb
    sudo apt-get update -qq && sudo apt-get install -y -qq powershell
  elif command -v yum &>/dev/null; then
    echo "  Using yum (RHEL/CentOS/Fedora) to install the repository's current PowerShell version."
    echo "  Note: yum may not install exactly ${POWERSHELL_VERSION}."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    curl -sSL "https://packages.microsoft.com/config/rhel/$(rpm -E %{rhel})/prod.repo" | sudo tee /etc/yum.repos.d/microsoft.repo
    sudo yum install -y powershell
  elif command -v brew &>/dev/null; then
    echo "  Using Homebrew (macOS) to install the tap's current PowerShell version."
    echo "  Note: Homebrew may not install exactly ${POWERSHELL_VERSION}."
    brew install powershell/tap/powershell
  else
    echo "  Installing exact PowerShell version ${POWERSHELL_VERSION} from GitHub release tarball..."
    local arch os_name pkg_os pkg_arch tarball install_dir
    arch="$(uname -m)"
    case "$arch" in
      x86_64) pkg_arch="x64" ;; aarch64|arm64) pkg_arch="arm64" ;;
      *) echo "Error: Unsupported architecture: $arch" >&2; exit 1 ;;
    esac
    os_name="$(uname -s)"
    case "$os_name" in
      Darwin) pkg_os="osx" ;;
      Linux) pkg_os="linux" ;;
      *) echo "Error: Unsupported operating system: $os_name" >&2; exit 1 ;;
    esac
    tarball="powershell-${POWERSHELL_VERSION}-${pkg_os}-${pkg_arch}.tar.gz"
    install_dir="/opt/microsoft/powershell/7"
    sudo mkdir -p "$install_dir"
    curl -fsSL "https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/${tarball}" -o "/tmp/${tarball}"
    sudo tar -xzf "/tmp/${tarball}" -C "$install_dir" && rm -f "/tmp/${tarball}"
    sudo chmod +x "$install_dir/pwsh"
    sudo ln -sf "$install_dir/pwsh" /usr/local/bin/pwsh
  fi
  echo "PowerShell installation complete."
}

# Runs an action immediately if AUTO_INSTALL_PWSH is true, otherwise prompts.
# Usage: prompt_or_auto "message" command [args...]
prompt_or_auto() {
  local prompt="$1"; shift
  local answer
  if [[ "$AUTO_INSTALL_PWSH" == "true" ]]; then
    "$@"
  else
    if [[ ! -t 0 ]]; then
      echo "Error: cannot prompt in non-interactive mode. Set AUTO_INSTALL_PWSH=true to allow automatic installation/upgrade, or run this script interactively." >&2
      return 1
    fi
    if ! read -rp "$prompt [y/N] " answer; then
      echo "Error: failed to read user input. Set AUTO_INSTALL_PWSH=true to allow automatic installation/upgrade, or run this script interactively." >&2
      return 1
    fi
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      "$@"
    else
      return 1
    fi
  fi
}

# Hard minimum PowerShell version required by the module manifest.
MIN_PWSH_VERSION="7.0"

# Ensures pwsh is installed and meets the minimum version.
ensure_pwsh() {
  echo "Checking for PowerShell..."
  if ! command -v pwsh &>/dev/null; then
    echo "PowerShell (pwsh) is not installed."
    if ! prompt_or_auto "Install PowerShell ${POWERSHELL_VERSION}?" install_powershell; then
      echo "Aborted. PowerShell 7+ is required." >&2; exit 1
    fi
    command -v pwsh &>/dev/null || { echo "Error: installation failed. See https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell" >&2; exit 1; }
    echo "PowerShell $(pwsh --version) is ready."
  else
    local installed_version
    installed_version="$(pwsh --version 2>/dev/null | sed 's/PowerShell //')"
    echo "PowerShell ${installed_version} found."
    # Enforce hard minimum required by the module manifest.
    if [ -n "$installed_version" ] && [ "$(printf '%s\n' "$MIN_PWSH_VERSION" "$installed_version" | sort -V | head -n1)" != "$MIN_PWSH_VERSION" ]; then
      echo "Error: PowerShell ${installed_version} is below the minimum required version ${MIN_PWSH_VERSION}." >&2
      echo "Please upgrade: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell" >&2
      exit 1
    fi
    if [ -n "$installed_version" ] && [ "$(printf '%s\n' "$POWERSHELL_VERSION" "$installed_version" | sort -V | head -n1)" != "$POWERSHELL_VERSION" ]; then
      echo "Warning: ${installed_version} is older than the recommended ${POWERSHELL_VERSION}."
      if ! prompt_or_auto "Upgrade to PowerShell ${POWERSHELL_VERSION}?" install_powershell; then
        echo "Continuing with PowerShell ${installed_version}."
      fi
    fi
  fi
}

# Confirms pwsh is on PATH and can execute successfully.
verify_pwsh() {
  local pwsh_path
  pwsh_path="$(command -v pwsh 2>/dev/null || true)"
  if [ -z "$pwsh_path" ]; then
    echo "Error: pwsh is not on PATH." >&2
    echo "Ensure /usr/local/bin or the install directory is in your PATH." >&2
    exit 1
  fi
  if ! "$pwsh_path" -NoProfile -Command 'exit 0' 2>/dev/null; then
    echo "Error: pwsh at ${pwsh_path} is not functional." >&2
    echo "Try reinstalling: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell" >&2
    exit 1
  fi
  echo "Verified pwsh at ${pwsh_path} ($(pwsh --version))."
}

# Queries the module's exported functions and caches the result.
# Output format per line: CommandName|Synopsis
ensure_module_commands() {
  if [ -n "$_MODULE_COMMANDS" ]; then return; fi
  echo "Querying available module commands..."
  _MODULE_COMMANDS="$(pwsh -NoProfile -Command "
    \$ProgressPreference = 'SilentlyContinue'
    \$WarningPreference = 'SilentlyContinue'
    & '${MODULE_DIR}/Initialize-Dependencies.ps1' *>&1 | Out-Null
    Import-Module '${MODULE_DIR}/ZeroTrustAssessment.psd1' -Force -WarningAction SilentlyContinue *>&1 | Out-Null
    Get-Command -Module ZeroTrustAssessment -CommandType Function |
      ForEach-Object {
        \$synopsis = ((Get-Help \$_.Name -ErrorAction Ignore).Synopsis -split '\n')[0].Trim()
        if (-not \$synopsis) { \$synopsis = '' }
        '{0}|{1}' -f \$_.Name, \$synopsis
      }
  " 2>/dev/null || true)"
}

# Prints usage with dynamically discovered commands and examples.
show_usage() {
  echo "Usage: $0 <command> [args...]"
  echo ""
  ensure_module_commands
  echo "Available commands:"
  if [ -n "$_MODULE_COMMANDS" ]; then
    local max_desc=60
    echo "$_MODULE_COMMANDS" | while IFS='|' read -r cmd synopsis; do
      if [ ${#synopsis} -gt $max_desc ]; then
        synopsis="${synopsis:0:$((max_desc - 3))}..."
      fi
      printf "  %-35s %s\n" "$cmd" "$synopsis"
    done
  else
    echo "  (Could not query module. Run '$0 Get-Help' after dependencies are installed.)"
  fi
  echo ""
  echo "Examples:"
  echo "  $0 Connect-ZtAssessment"
  echo "  $0 Connect-ZtAssessment -UseDeviceCode"
  echo "  $0 Invoke-ZtAssessment"
  echo "  $0 Get-ZtTest"
  echo ""
  echo "For detailed help on any command:"
  echo "  $0 Get-Help Connect-ZtAssessment -Full"
}

# Validates that the given command is an exported module function.
# Get-Help and known safe commands are always allowed.
# If module discovery fails, only the safe allowlist is permitted.
validate_command() {
  local cmd="$1"
  # Safe allowlist: commands accepted even when discovery fails.
  local -a safe_commands=("get-help" "connect-ztassessment" "invoke-ztassessment"
                          "disconnect-ztassessment" "get-zttest" "get-ztteststatistics")
  local lc_cmd="${cmd,,}"
  for safe in "${safe_commands[@]}"; do
    if [[ "$lc_cmd" == "$safe" ]]; then return 0; fi
  done
  ensure_module_commands
  if [ -z "$_MODULE_COMMANDS" ]; then
    echo "Error: Could not discover module commands; refusing to run unrecognised command '${cmd}'." >&2
    echo "Only the following commands are allowed when discovery fails:" >&2
    for safe in "${safe_commands[@]}"; do echo "  $safe" >&2; done
    exit 1
  fi
  local valid_names
  valid_names="$(printf '%s\n' "$_MODULE_COMMANDS" | cut -d'|' -f1)"
  if ! printf '%s\n' "$valid_names" | grep -Fxiq -- "$cmd"; then
    echo "Error: Unknown command '${cmd}'." >&2
    echo "" >&2
    show_usage >&2
    exit 1
  fi
}

# --- Main ---

ensure_pwsh
verify_pwsh

if [ $# -eq 0 ]; then
  show_usage >&2
  exit 1
fi

validate_command "$1"
echo "Running: $1"

# If invoking the assessment, automatically connect first in the same session.
if [[ "${1,,}" == "invoke-ztassessment" ]]; then
  echo "Will connect to services before running the assessment."
  CONNECT_FIRST="Connect-ZtAssessment"
  echo "Will connect to services before running the assessment."
fi

echo "Loading ZeroTrustAssessment module and running command..."
exec pwsh -NoProfile -Command '
  param($moduleDir, $connectFirst, $cmd, $rest)
  & "$moduleDir/Initialize-Dependencies.ps1"
  Import-Module "$moduleDir/ZeroTrustAssessment.psd1" -Force
  if ($connectFirst) { & $connectFirst }
  & $cmd @rest
' -- "$MODULE_DIR" "$CONNECT_FIRST" "$1" "${@:2}"
    & $args[0] @($args[1..($args.Length - 1)])
  } else {
    & $args[0]
  }
' -- "$@"
