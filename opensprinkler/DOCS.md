# OpenSprinkler Home Assistant Add-on

This add-on runs the **OpenSprinkler Firmware** directly within Home Assistant.

## Features
- **Full OpenSprinkler UI**: Access the complete OpenSprinkler interface.
- **Ingress Support**: Secure access via Home Assistant sidebar (no port forwarding needed).
- **Direct Access**: Optional direct port access (default: 8080) for mobile apps.
- **Smart Config**: Preserves your `admin_password` and settings across restarts.

## Installation & Configuration

1.  **Install**: Click the "Install" button.
2.  **Configure**:
    *   Go to the **Configuration** tab.
    *   Set your `admin_password` (Default: `opendoor`).
    *   *Optional*: Change the HTTP Port if using direct access.
3.  **Start**: Click "Start".
4.  **Open**: Click "Open Web UI" to see the interface.

## Mobile App Setup (Direct Access)
To use the official OpenSprinkler mobile app:
1.  Go to the **Network** tab of this add-on.
2.  Map **Container Port 8080** to a Host Port (e.g., `8080`).
3.  In the mobile app, add a device using your Home Assistant IP and that port (e.g., `192.168.1.100:8080`).

## Notes
- **Hardware Access**: This container attempts to access GPIO for Raspberry Pi (OpenSprinkler Pi) hardware. If you are running Home Assistant on a generic PC/VM, this is fine—the software will run in "Demo Mode" or without hardware control, which is still perfect for managing smart watering logic if you use external stations or testing.
- **Password**: The password you set in the "Configuration" tab takes precedence. If you change it in the OpenSprinkler UI, it may be reset to the Add-on value on restart.

## Support
For issues with the firmware logic, visit the [OpenSprinkler Forums](https://opensprinkler.com/forums/).
For issues with this specific Add-on container, submit an issue on the [GitHub Repository](https://github.com/Jxck-S/opensprinkler-docker).
