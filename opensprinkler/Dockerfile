

# Helper stage to build liblgpio if not available or for consistency
FROM debian:trixie-slim AS lgpio-builder
WORKDIR /usr/src
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    make \
    python3-dev \
    swig \
    && rm -rf /var/lib/apt/lists/*

# Clone and build liblgpio (using joan2937/lg as widely used source for RPi/Linux GPIO)
# Note: For generic Linux/amd64 without GPIO, this might build but not function for hardware control.
# Users on amd64 might prefer 'DEMO' mode, but we'll try to provide libraries for OSPI mode executable.
RUN git clone https://github.com/joan2937/lg.git && \
    cd lg && \
    make && \
    make install

FROM debian:trixie-slim AS builder
WORKDIR /usr/src

# Install OpenSprinkler build dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libmosquitto-dev \
    libssl-dev \
    libi2c-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy liblgpio artifacts from lgpio-builder
COPY --from=lgpio-builder /usr/local/lib/liblgpio.so /usr/lib/
COPY --from=lgpio-builder /usr/local/include/lgpio.h /usr/include/
# Ensure linker finds it
RUN ldconfig

# Build OpenSprinkler
# We clone the repo. We use a specific commit or tag if desired, but master is requested.
RUN git clone https://github.com/OpenSprinkler/OpenSprinkler-Firmware.git && \
    cd OpenSprinkler-Firmware && \
    # Initialize submodules if any (though currently mostly flat, good practice) \
    git submodule update --init --recursive && \
    # Build the OSPI version (standard Linux version)
    make VERSION=OSPI

FROM debian:trixie-slim

# Runtime dependencies
RUN apt-get update && apt-get install -y \
    libmosquitto1 \
    libssl3t64 \
    libi2c0 \
    python3-minimal \
    # liblgpio runtime (we will copy if not in repo) \
    && rm -rf /var/lib/apt/lists/*

# Copy liblgpio from builder (it might not be in debian repos yet)
COPY --from=lgpio-builder /usr/local/lib/liblgpio.so /usr/lib/
RUN ldconfig

WORKDIR /OpenSprinkler

# Copy build artifacts
COPY --from=builder /usr/src/OpenSprinkler-Firmware/OpenSprinkler /OpenSprinkler/OpenSprinkler
COPY --from=builder /usr/src/OpenSprinkler-Firmware/*.js /OpenSprinkler/
COPY --from=builder /usr/src/OpenSprinkler-Firmware/*.html /OpenSprinkler/
COPY --from=builder /usr/src/OpenSprinkler-Firmware/*.css /OpenSprinkler/
COPY --from=builder /usr/src/OpenSprinkler-Firmware/*.ico /OpenSprinkler/
COPY --from=builder /usr/src/OpenSprinkler-Firmware/*.png /OpenSprinkler/
# Copy the stc directory (standard config/assets) if it exists, logic in start script might handle generation
# Usually OpenSprinkler generates files in runtime dir.

# Home Assistant Add-on / Docker specific setup
COPY gen_config.py /gen_config.py
RUN chmod +x /gen_config.py

COPY run.sh /run.sh
RUN chmod +x /run.sh

# Persist data
VOLUME /data

# Expose port (OpenSprinkler default 8080)
EXPOSE 8080

ENTRYPOINT ["/run.sh"]
