#!/bin/bash
# =============================================================================
# Best Modpack - Forge 1.12.2 Server Start Script
# =============================================================================
set -e

MAX_MEMORY="${JAVA_XMX:-4G}"
MIN_MEMORY="${JAVA_XMS:-2G}"

echo "============================================="
echo " Best Modpack Server"
echo " Minecraft 1.12.2 | Forge 14.23.5.2860"
echo " Max Memory: ${MAX_MEMORY}"
echo " Min Memory: ${MIN_MEMORY}"
echo "============================================="

cd /server

# Ensure EULA
if [ ! -f eula.txt ] || ! grep -q "eula=true" eula.txt; then
    echo "eula=true" > eula.txt
fi

echo "[STARTUP] Starting Forge 1.12.2 server..."
# Find the Forge server jar dynamically
FORGE_JAR=$(find /server -maxdepth 1 -name "forge-*.jar" ! -name "*installer*" | sort | tail -1)
if [ -z "$FORGE_JAR" ]; then
    echo "[ERROR] Could not find Forge server jar! Contents of /server:"
    ls -la /server/
    exit 1
fi
echo "[STARTUP] Using jar: $FORGE_JAR"
exec java \
    -Xmx${MAX_MEMORY} \
    -Xms${MIN_MEMORY} \
    -XX:+UseG1GC \
    -XX:+ParallelRefProcEnabled \
    -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+DisableExplicitGC \
    -XX:+AlwaysPreTouch \
    -Dfml.readTimeout=60 \
    -Dfml.loginTimeout=60 \
    -jar $FORGE_JAR nogui
    -jar $FORGE_JAR nogui
