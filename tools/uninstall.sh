#!/usr/bin/env bash

# Uninstall Script for KIK with Gum
set -euo pipefail

# Paths
INSTALL_BASE_PATH=${INSTALL_BASE_PATH:-$HOME/.kik}
CONFIG_PATH=${CONFIG_PATH:-$INSTALL_BASE_PATH/config/kik.example.conf}

# Uninstallation Script
#uninstall_deployment_tool() {
#    gum confirm "Are you sure you want to uninstall the deployment tool?" && {
#        gum spin --spinner dot --title "Uninstalling..." -- bash -c '
#            rm -rf "'${INSTALL_BASE_PATH}'"
#            rm -rf "'${CONFIG_PATH}'"
#            rm -f /usr/local/bin/deployment_tool
#        '
#
#        gum style --foreground 2 "Deployment tool successfully uninstalled!"
#    }
#}


# Gum welcome message
gum style --foreground 212 --border normal --margin "1" --padding "1" "Uninstall KIK"

# Confirmation prompt with Gum
if ! gum confirm "Are you sure you want to uninstall KIK?"; then
    gum style --foreground 214 "Uninstallation canceled."
    exit 0
fi

# Remove files with progress using Gum
gum spin --spinner dot --title "Removing installation files..." -- sleep 2

rm -rf "$INSTALL_BASE_PATH"
rm -f /usr/local/bin/kik

gum style --foreground 10 --border normal --margin "1" --padding "1" "KIK has been successfully uninstalled!"
