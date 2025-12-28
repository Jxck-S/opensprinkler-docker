# OpenSprinkler Docker & Home Assistant Add-on

Multi-architecture OpenSprinkler Firmware build based on Debian Trixie. Supports `amd64`, `arm64`, and `armv7` (Raspberry Pi).

> [!IMPORTANT]
> **Scope & Functionality**: 
> *   This is **NOT a Home Assistant Integration**. It does not create entities (sensors, switches) in Home Assistant. For that, we recommend using the [Hass OpenSprinkler Integration](https://github.com/vinteo/hass-opensprinkler)  this Add-on.
> *   It is an **Add-on** that runs the full OpenSprinkler Firmware as a container. Use it to connect to remote stations (HTTP) or use the Web UI directly.
> *   **GPIO Support**: While the build includes `liblgpio`, driving GPIO pins on a Raspberry Pi from within this Add-on container is **Untested** and may not work out of the box.

## 🚀 Standalone Usage (Docker / Compose)

This mode is for running OpenSprinkler on a standard Linux server, Raspberry Pi, or desktop.

### Option 1: Docker Compose (Recommended)

1. **Clone/Download** this repository.
2. Review `docker-compose.yml`.
3. Run:
   ```bash
   docker-compose up -d --build
   ```
4. Access the web interface at **[http://localhost:8080](http://localhost:8080)**.

### Option 2: Docker CLI

```bash
docker build -t opensprinkler .

docker run -d \
  --name opensprinkler \
  -p 8080:8080 \
  -v $(pwd)/data:/data \
  -e ADMIN_PASSWORD=mysecretpassword \
  opensprinkler
```

---

## 🏠 Home Assistant Add-on

This image is structured to work as a **Local Add-on** in Home Assistant (HAOS).

### Installation Steps

#### Option 1: One-Line Install (Easy)
Run this command in your Home Assistant SSH terminal:
```bash
wget -O - https://raw.githubusercontent.com/Jxck-S/opensprinkler-docker/refs/heads/master/install_ha.sh | bash
```

#### Option 2: Manual Install
1. **Access HA File System**:
   - Use the **Samba Share** add-on or SSH.
   - Navigate to `/addons`.
2. **Upload Files**:
   - Create folder `opensprinkler`.
   - Copy all repo files into `/addons/opensprinkler/`.

3. **Install**:
   - Go to **Settings > Add-ons > Add-on Store**.
   - Click the **three dots** (top right) -> **Check for updates**.
   - You should see **OpenSprinkler Firmware** appear under "Local Add-ons".
   - Click **Install**.

4. **Configure**:
   - **Configuration Tab**: Set your `admin_password`.
   - **Network Tab**: Map the Container Port `8080` to your desired Host Port (e.g., `80` or `8080`).

5. **Start**:
   - Click **Start**. Check the logs to verify it initializes correctly.

---

## ⚙️ Configuration

The container includes a "Smart Patch" script that applies configuration on boot without overwriting your station data.

### Environment Variables

| Variable | Description | Default | Notes |
|----------|-------------|---------|-------|
| `ADMIN_PASSWORD` | Sets the Web UI password | `opendoor` | Applied to `sopts.dat` on every boot. |
| `HTTP_PORT` | Internal listening port | `8080` | **Standalone Only**. In HA, use Network mapping. |

### Volumes

| Path | Description |
|------|-------------|
| `/data` | **Required**. Stores all configuration (`*.dat`) and station data. Map this to a persistent folder. |

## 🔧 Technical Details

- **Base OS**: Debian Trixie Slim
- **GPIO Support**: Includes `liblgpio` built from source.
- **Port Management**:
  - **HA Mode**: Internal port is locked to `8080` to prevent mapping conflicts. External port is controlled by HA.
  - **Standalone**: Internal port can be changed via `HTTP_PORT` env var (though standard port mapping is preferred).

## 🔄 Execution Flow

Understanding how configuration is applied:

### Standalone Docker
1. **User** starts container with `-e ADMIN_PASSWORD=secret`.
2. **`run.sh`** starts.
3. Checks for first run -> runs OpenSprinkler momentarily to generate default `*.dat` files.
4. Runs `python3 /gen_config.py`.
5. Script detects **Environment Variable** `ADMIN_PASSWORD`.
6. Script patches `sopts.dat` with hashed password.
7. OpenSprinkler starts.

### Home Assistant
1. **User** saves configuration in HA UI.
2. **Supervisor** writes `admin_password` to `/data/options.json`.
3. **Supervisor** starts container.
4. **`run.sh`** starts.
5. Checks for first run -> generates defaults.
6. Runs `python3 /gen_config.py`.
7. Script detects **`/data/options.json`**.
8. Script patches `sopts.dat` with hashed password from JSON.
9. OpenSprinkler starts.
