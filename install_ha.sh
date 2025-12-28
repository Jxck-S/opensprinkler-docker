#!/bin/bash
set -e

# Target Directory
ADDON_DIR="/addons/opensprinkler"
REPO_URL="https://raw.githubusercontent.com/Jxck-S/opensprinkler-docker/refs/heads/master"

echo "Started OpenSprinkler Add-on Installation..."

# 1. Create Directory
if [ -d "$ADDON_DIR" ]; then
    echo "Directory $ADDON_DIR already exists. Updating files..."
else
    echo "Creating directory $ADDON_DIR..."
    mkdir -p "$ADDON_DIR"
fi

# 2. Download Files
echo "Downloading files from GitHub..."
cd "$ADDON_DIR"

wget -O Dockerfile "$REPO_URL/Dockerfile"
wget -O config.yaml "$REPO_URL/config.yaml"
wget -O run.sh "$REPO_URL/run.sh"
wget -O gen_config.py "$REPO_URL/gen_config.py"
wget -O icon.png "$REPO_URL/icon.png"

# 3. Set Permissions
echo "Setting permissions..."
chmod +x run.sh
chmod +x gen_config.py

echo "------------------------------------------------"
echo "✅ Installation Complete!"
echo "------------------------------------------------"
echo "Next Steps:"
echo "1. Go to Home Assistant > Settings > Add-ons > Add-on Store."
echo "2. Click the 3 dots (top right) > Check for updates."
echo "3. Find 'OpenSprinkler Firmware' in the list and Install."
echo "------------------------------------------------"
