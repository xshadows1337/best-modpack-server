# =============================================================================
# GT New Horizons 2.8.4 Server - Railway Deployment
# =============================================================================
# Minecraft 1.7.10 | Forge (GTNH Custom) | Java 21
# =============================================================================

FROM eclipse-temurin:21-jre-jammy AS base

# Install required utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl unzip jq && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN groupadd -r minecraft && useradd -r -g minecraft -d /server minecraft

WORKDIR /server

# =============================================================================
# Download and extract GTNH server pack
# =============================================================================
ARG GTNH_VERSION=2.8.4
ARG GTNH_SERVER_URL=https://downloads.gtnewhorizons.com/ServerPacks/GT_New_Horizons_${GTNH_VERSION}_Server_Java_17-25.zip

RUN echo "Downloading GTNH ${GTNH_VERSION} server pack..." && \
    curl -fSL -o /tmp/gtnh-server.zip "${GTNH_SERVER_URL}" && \
    echo "Extracting server pack..." && \
    unzip -o /tmp/gtnh-server.zip -d /server && \
    rm /tmp/gtnh-server.zip && \
    echo "GTNH server pack extracted successfully."

# =============================================================================
# Accept Minecraft EULA (required to start the server)
# =============================================================================
RUN echo "eula=true" > /server/eula.txt

# =============================================================================
# Copy custom configs
# =============================================================================
COPY server.properties /server/server.properties
COPY start.sh /server/start.sh

# Make scripts executable
RUN chmod +x /server/start.sh && \
    chmod +x /server/*.sh 2>/dev/null || true && \
    chown -R minecraft:minecraft /server

# Persistent world data is handled by Railway volumes (configured in dashboard)
# Mount point: /server/world

# Minecraft default port
EXPOSE 25565

USER minecraft

# Health check - verify the server process is running
HEALTHCHECK --interval=60s --timeout=10s --start-period=300s --retries=3 \
    CMD pgrep -f "java" > /dev/null || exit 1

ENTRYPOINT ["/server/start.sh"]
