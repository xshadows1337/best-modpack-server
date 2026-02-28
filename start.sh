#!/bin/bash
# Forge 1.12.2 Server
set -e
MAX_MEMORY="${JAVA_XMX:-4G}"
MIN_MEMORY="${JAVA_XMS:-2G}"
cd /server
if [ ! -f eula.txt ]; then echo "eula=true" > eula.txt; fi

# One-time world reset: clears old/incompatible world (e.g. leftover Fabric world data)
# After first clean start, marker file persists on volume to prevent repeated resets.
MARKER="/server/world/.forge_1.12.2_jeid_marker"
if [ ! -f "$MARKER" ] || [ "${RESET_WORLD:-false}" = "true" ]; then
    echo "[STARTUP] Clearing old world data (reset: fresh world with JEID active)..."
    # Can't rm -rf the mount point itself; clear contents instead
    find /server/world -mindepth 1 -delete 2>/dev/null || true
    touch "$MARKER"
    echo "[STARTUP] World cleared. Forge 1.12.2 will generate fresh world with JEID."
fi

FORGE_JAR=$(find /server -maxdepth 1 -name "forge-*.jar" ! -name "*installer*" | sort | tail -1)
if [ -z "$FORGE_JAR" ]; then ls -la /server/; exit 1; fi
echo "[STARTUP] Using jar: $FORGE_JAR"
exec java -Xmx${MAX_MEMORY} -Xms${MIN_MEMORY} -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -Dfml.readTimeout=60 -Dfml.loginTimeout=60 -jar $FORGE_JAR nogui
