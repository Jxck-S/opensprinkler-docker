#!/bin/bash
set -e

# Default configuration directory
CONFIG_DIR="/data"
APP_DIR="/OpenSprinkler"

echo "Starting OpenSprinkler Firmware..."

# Check if we are in Home Assistant Add-on environment
if [ -f "/data/options.json" ]; then
    echo "Home Assistant Add-on mode detected."
    # We could parse options here if needed to configure OpenSprinkler
    # OpenSprinkler stores configs in *.json files in the execution directory or specified path.
    # By default it looks in current dir.
    
    # Example: Parse port from options.json (jq is useful if installed, or just grep/sed)
    # However, OpenSprinkler binary usually takes args or uses 'opts.h' defines compiled in.
    # It seems to verify password on first login or stores it in 'password.txt' / 'remote_password.txt'?
    # We'll rely on OpenSprinkler's internal storage for now, mapped to /data.
fi

# Link /data storage to current directory so OpenSprinkler saves files there
# OpenSprinkler writes to executable directory by default for some files (nvm.dat, etc.)
# We create symlinks or run from /data and copy assets.

# Strategy: Run in /data, link assets back to /OpenSprinkler
# OR: Run in /OpenSprinkler, but symlink config files to /data

# Check if this is a first run (done.dat missing)
if [ ! -f "$CONFIG_DIR/done.dat" ]; then
    echo "First run detected. Initializing configuration..."
    
    # Start OpenSprinkler in background to generate default config files
    # Use -d to specify data directory
    ./OpenSprinkler -d "$CONFIG_DIR" &
    PID=$!
    
    # Wait for done.dat to appear (max 30 seconds)
    TIMEOUT=30
    COUNT=0
    while [ ! -f "$CONFIG_DIR/done.dat" ]; do
        sleep 1
        COUNT=$((COUNT+1))
        if [ $COUNT -ge $TIMEOUT ]; then
            echo "Timeout waiting for OpenSprinkler to initialize."
            kill $PID
            exit 1
        fi
    done
    
    echo "Default configuration generated."
    
    # Kill the background process
    kill $PID
    wait $PID 2>/dev/null
fi

# ALWAYS Patch the configuration with our options (Read-Modify-Write)
echo "Applying Configuration Options..."
if command -v python3 &> /dev/null; then
    python3 /gen_config.py
else
    echo "Python3 not found, skipping configuration patch."
fi

# Ensure /data exists (redundant but safe)
mkdir -p "$CONFIG_DIR"

# Symlink static assets from $APP_DIR to $CONFIG_DIR
# This ensures the web UI works when running from /data
# NOTE: We are running from /OpenSprinkler (WORKDIR), so assets are already here.
# Only needed if we were running from /data or if firmware looks in -d dir for assets.
# Assuming firmware serves from CWD.
# find "$APP_DIR" -maxdepth 1 -type f \( -name "*.js" -o -name "*.html" -o -name "*.css" -o -name "*.ico" -o -name "*.png" \) -exec ln -sf {} . \;

# Symlink the binary
# ln -sf "$APP_DIR/OpenSprinkler" .

echo "Launching OpenSprinkler..."
exec ./OpenSprinkler -d "$CONFIG_DIR"
