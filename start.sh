#!/bin/bash
# =============================================================================
# GT New Horizons Server Start Script for Railway
# =============================================================================
set -e

# ---- Memory Configuration ----
# Railway provides memory via environment; default to 4G if not set.
# Use JAVA_XMX / JAVA_XMS env vars to override.
MAX_MEMORY="${JAVA_XMX:-6G}"
MIN_MEMORY="${JAVA_XMS:-4G}"

echo "============================================="
echo " GT New Horizons Server"
echo " Version: ${GTNH_VERSION:-2.8.4}"
echo " Max Memory: ${MAX_MEMORY}"
echo " Min Memory: ${MIN_MEMORY}"
echo "============================================="

cd /server

# ---- Ensure EULA is accepted ----
if [ ! -f eula.txt ] || ! grep -q "eula=true" eula.txt; then
    echo "eula=true" > eula.txt
    echo "[STARTUP] EULA accepted."
fi

# ---- Detect the Forge/server JAR ----
# GTNH Java 17+ server pack uses a custom start script or forge jar
# Try to find the correct jar to launch

# First check if there's a java9args.txt (GTNH Java 17+ pack includes this)
JAVA9_ARGS=""
if [ -f "java9args.txt" ]; then
    JAVA9_ARGS=$(cat java9args.txt | tr '\n' ' ')
    echo "[STARTUP] Found java9args.txt, using Java 17+ arguments."
fi

# Find the forge server jar
FORGE_JAR=""
if [ -f "forge-*.jar" ]; then
    FORGE_JAR=$(ls forge-*.jar 2>/dev/null | head -1)
fi

if [ -z "$FORGE_JAR" ]; then
    # Try finding any forge universal jar
    FORGE_JAR=$(find /server -maxdepth 1 -name "forge-*-universal.jar" -o -name "forge-*.jar" | head -1)
fi

if [ -z "$FORGE_JAR" ]; then
    # Check for minecraft_server jar as fallback
    FORGE_JAR=$(find /server -maxdepth 1 -name "minecraft_server*.jar" | head -1)
fi

# If there's a startserver-java9.sh script from the GTNH pack, use its logic
if [ -f "startserver-java9.sh" ] && [ -n "$JAVA9_ARGS" ]; then
    echo "[STARTUP] Using GTNH Java 17+ start configuration..."
    
    # Extract the jar name from the GTNH start script
    GTNH_JAR=$(grep -oP '(?<=-jar\s)[^\s]+' startserver-java9.sh 2>/dev/null || echo "")
    if [ -n "$GTNH_JAR" ] && [ -f "$GTNH_JAR" ]; then
        FORGE_JAR="$GTNH_JAR"
    fi
fi

if [ -z "$FORGE_JAR" ]; then
    echo "[ERROR] Could not find forge/server JAR file!"
    echo "[ERROR] Contents of /server:"
    ls -la /server/
    exit 1
fi

echo "[STARTUP] Using JAR: ${FORGE_JAR}"

# ---- Build Java arguments ----
JAVA_OPTS=(
    -Xmx${MAX_MEMORY}
    -Xms${MIN_MEMORY}
    -XX:+UseG1GC
    -XX:+ParallelRefProcEnabled
    -XX:MaxGCPauseMillis=200
    -XX:+UnlockExperimentalVMOptions
    -XX:+DisableExplicitGC
    -XX:+AlwaysPreTouch
    -XX:G1NewSizePercent=30
    -XX:G1MaxNewSizePercent=40
    -XX:G1HeapRegionSize=8M
    -XX:G1ReservePercent=20
    -XX:G1HeapWastePercent=5
    -XX:G1MixedGCCountTarget=4
    -XX:InitiatingHeapOccupancyPercent=15
    -XX:G1MixedGCLiveThresholdPercent=90
    -XX:G1RSetUpdatingPauseTimePercent=5
    -XX:SurvivorRatio=32
    -XX:+PerfDisableSharedMem
    -XX:MaxTenuringThreshold=1
    -Dfml.readTimeout=180
    -Dfml.queryResult=confirm
)

# Add Java 9+ specific args if available
if [ -n "$JAVA9_ARGS" ]; then
    JAVA_OPTS+=($JAVA9_ARGS)
fi

# Add lwjgl3ify forge patches if present
if [ -f "lwjgl3ify-forgePatches.jar" ]; then
    echo "[STARTUP] Found lwjgl3ify forge patches."
fi

echo "[STARTUP] Starting server..."
echo "[STARTUP] Command: java ${JAVA_OPTS[*]} -jar ${FORGE_JAR} nogui"

# ---- Graceful shutdown handling ----
trap 'echo "[SHUTDOWN] Received SIGTERM, stopping server..."; kill -TERM $SERVER_PID 2>/dev/null; wait $SERVER_PID' SIGTERM SIGINT

# ---- Start the server ----
exec java "${JAVA_OPTS[@]}" -jar "${FORGE_JAR}" nogui
