# =============================================================================
# Distant Horizons & Iris Shaders - Fabric Server for Railway
# =============================================================================
# Minecraft 1.21.8 | Fabric 0.16.14 | Java 21
# =============================================================================

FROM eclipse-temurin:21-jre-jammy AS base

# Install required utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /server

# =============================================================================
# Download Fabric server launcher jar
# =============================================================================
ARG MC_VERSION=1.21.8
ARG FABRIC_LOADER_VERSION=0.18.0
ARG FABRIC_INSTALLER_VERSION=1.0.1

RUN echo "Downloading Fabric ${FABRIC_LOADER_VERSION} for MC ${MC_VERSION}..." && \
    curl -fSL -o /server/fabric-server-launch.jar \
    "https://meta.fabricmc.net/v2/versions/loader/${MC_VERSION}/${FABRIC_LOADER_VERSION}/${FABRIC_INSTALLER_VERSION}/server/jar" && \
    echo "Fabric server jar ready."

# =============================================================================
# Accept Minecraft EULA
# =============================================================================
RUN echo "eula=true" > /server/eula.txt

# =============================================================================
# Copy server files (mods, configs, properties, start script)
# =============================================================================
COPY mods/ /server/mods/
COPY config/ /server/config/
COPY server.properties /server/server.properties
COPY start.sh /server/start.sh

RUN chmod +x /server/start.sh

# Persistent world data via Railway volume at /server/world

# Minecraft default port
EXPOSE 25565

# Health check
HEALTHCHECK --interval=60s --timeout=10s --start-period=180s --retries=3 \
    CMD pgrep -f "java" > /dev/null || exit 1

ENTRYPOINT ["/server/start.sh"]
