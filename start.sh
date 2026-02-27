#!/bin/bash
# =============================================================================
# Distant Horizons & Iris Shaders - Fabric Server Start Script
# =============================================================================
set -e

MAX_MEMORY="${JAVA_XMX:-4G}"
MIN_MEMORY="${JAVA_XMS:-2G}"

echo "============================================="
echo " Distant Horizons & Iris Shaders Server"
echo " Minecraft 1.21.8 | Fabric"
echo " Max Memory: ${MAX_MEMORY}"
echo " Min Memory: ${MIN_MEMORY}"
echo "============================================="

cd /server

# Ensure EULA
if [ ! -f eula.txt ] || ! grep -q "eula=true" eula.txt; then
    echo "eula=true" > eula.txt
fi

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
)

echo "[STARTUP] Starting Fabric server..."
exec java "${JAVA_OPTS[@]}" -jar fabric-server-launch.jar nogui
