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
    -jar forge-1.12.2-14.23.5.2860-universal.jar nogui
    -jar forge-1.12.2-14.23.5.2860-universal.jar nogui
