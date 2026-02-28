FROM eclipse-temurin:8-jre-jammy

RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

WORKDIR /server

# Download and install Forge 1.12.2 server
RUN curl -fsSL -o forge-installer.jar \
    "https://maven.minecraftforge.net/net/minecraftforge/forge/1.12.2-14.23.5.2860/forge-1.12.2-14.23.5.2860-installer.jar" \
    && java -jar forge-installer.jar --installServer \
    && rm forge-installer.jar

# Accept EULA
RUN echo "eula=true" > /server/eula.txt

# Download mods from GitHub Release (avoids Railway upload size limit)
# mods-version: v1.0.7 (removed Sky Islands, using DEFAULT world type)
RUN mkdir -p /server/mods && \
    curl -fsSL -o /tmp/mods.zip \
    "https://github.com/xshadows1337/best-modpack-server/releases/download/v1.0/mods_v7.zip" && \
    unzip -q /tmp/mods.zip -d /server/mods/ && \
    rm /tmp/mods.zip

# Copy configs
COPY config/ /server/config/
COPY server.properties /server/server.properties
COPY ops.json /server/ops.json
COPY start.sh /server/start.sh
RUN sed -i 's/\r//' /server/start.sh && chmod +x /server/start.sh

EXPOSE 25565
ENTRYPOINT ["/server/start.sh"]
