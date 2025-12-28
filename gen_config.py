import os
import json
import hashlib
import struct
import time

# Configuration Paths
DATA_DIR = "/data"
OPTIONS_FILE = "/data/options.json"

# File Constants
IOPTS_FILENAME = os.path.join(DATA_DIR, "iopts.dat")
SOPTS_FILENAME = os.path.join(DATA_DIR, "sopts.dat")
DONE_FILENAME = os.path.join(DATA_DIR, "done.dat")

# Definitions from Firmware
MAX_SOPTS_SIZE = 320
NUM_SOPTS = 13

# Offsets based on defines.h / OpenSprinkler.cpp
# sopts indices
SOPT_PASSWORD = 0

def get_config_values():
    """
    Retrieve configuration from options.json or environment variables.
    Returns a dict with 'admin_password'.
    """
    config = {}

    # 1. Try Home Assistant options
    if os.path.exists(OPTIONS_FILE):
        try:
            with open(OPTIONS_FILE, 'r') as f:
                options = json.load(f)
                if "admin_password" in options and options["admin_password"]:
                    config["admin_password"] = options["admin_password"]
            print(f"Loaded config from {OPTIONS_FILE}")
        except Exception as e:
            print(f"Error reading {OPTIONS_FILE}: {e}")

    # 2. Try Environment Variables (override HA if set, or standalone usage)
    if "ADMIN_PASSWORD" in os.environ and os.environ["ADMIN_PASSWORD"]:
        config["admin_password"] = os.environ["ADMIN_PASSWORD"]

    return config

def patch_sopts(password):
    """
    Patch sopts.dat with new Password.
    Preserves all other settings.
    """
    if not os.path.exists(SOPTS_FILENAME):
        print(f"Warning: {SOPTS_FILENAME} not found. Skipping password patch.")
        return

    # Hash password
    md5_pass = hashlib.md5(password.encode()).hexdigest()
    
    print(f"Checking {SOPTS_FILENAME} for password update...")
    try:
        with open(SOPTS_FILENAME, "r+b") as f:
            # SOPT_PASSWORD is at index 0, so offset 0.
            f.seek(SOPT_PASSWORD * MAX_SOPTS_SIZE)
            
            # Prepare byte block
            b = md5_pass.encode('utf-8')
            # Pad to 320 bytes with nulls
            padded = b + b'\x00' * (MAX_SOPTS_SIZE - len(b))
            
            # Read existing
            current_data = f.read(MAX_SOPTS_SIZE)
            
            if current_data == padded:
                print("Password hash matches existing config. No change needed.")
            else:
                # Seek back to write
                f.seek(SOPT_PASSWORD * MAX_SOPTS_SIZE)
                f.write(padded)
                print("Password updated successfully.")
    except Exception as e:
        print(f"Error patching sopts.dat: {e}")

def main():
    print("Starting configuration patcher...")
    
    # Wait briefly for file system to settle if just initialized
    if not os.path.exists(SOPTS_FILENAME):
        print("Waiting for config files to appear...")
        time.sleep(1)

    config = get_config_values()
        
    if "admin_password" in config:
        patch_sopts(config["admin_password"])
    else:
        print("No ADMIN_PASSWORD provided, skipping password patch.")
        
if __name__ == "__main__":
    main()
