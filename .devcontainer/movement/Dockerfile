##############################################
# Builder Stage
##############################################
# Base image
FROM rust:latest as builder
ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_BUILD_JOBS=8

# Set default values for ARGs
ARG APP_DIR="/root/movement/app"
ARG SUBNET_DIR="/root/movement/subnet"
ARG LOCALNET_DIR="/root/movement/localnet"
ARG CLI_DIR="/root/movement/cli"
ARG PLUGIN_DIR="/root/movement/plugins"
ARG SETUP_DIR="/root/movement/setup"

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    pkg-config \
    libudev-dev \
    openssh-client \
    sudo

# Download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Clone repo
RUN --mount=type=ssh git clone git@github.com:movemntdev/movement-subnet.git "$APP_DIR/movement-subnet"

# Create directories if they don't exist
RUN mkdir -p "$APP_DIR" \
    "$SUBNET_DIR" \
    "$LOCALNET_DIR" \
    "$CLI_DIR" \
    "$PLUGIN_DIR"

# Set the working directory
WORKDIR "$APP_DIR/movement-subnet/vm/aptos-vm"

# Pre-fetch crates
RUN cargo generate-lockfile
RUN cargo fetch
# RUN cargo vendor

# Run dev_setup.sh
RUN chmod -R 755 ./scripts/dev_setup.sh && echo "y" | ./scripts/dev_setup.sh

### SUBNET ###
# Build subnet
RUN cargo build -j $CARGO_BUILD_JOBS -p subnet --release

# Copy the subnet binary to the plugins directory
RUN cp "$APP_DIR/movement-subnet/vm/aptos-vm/target/release/subnet" "$PLUGIN_DIR/b6z34iYog6Qm8uUWmssHYWDhShhufDC1XEkXDQRabFWA3Ac6Y"

# Download avalanchego
RUN curl -L -o "$SUBNET_DIR/avalanchego.tar.gz" "https://github.com/ava-labs/avalanchego/releases/download/v1.10.2/avalanchego-linux-arm64-v1.10.2.tar.gz"

# Extract avalanchego
RUN tar -xzf "$SUBNET_DIR/avalanchego.tar.gz" -C "$SUBNET_DIR"

### CLI ###
WORKDIR "$APP_DIR/movement-subnet/vm/aptos-vm/crates/aptos"

# Build cli
RUN cargo build -j $CARGO_BUILD_JOBS --release

# Copy the cli binary to the cli directory
RUN cp "$APP_DIR/movement-subnet/vm/aptos-vm/target/release/aptos" "$CLI_DIR"

RUN ls ${CLI_DIR} && sleep 10

# Add the local tesnet client
RUN curl -sSfL https://raw.githubusercontent.com/ava-labs/avalanche-network-runner/main/scripts/install.sh | sh -s

RUN cp /$HOME/bin/avalanche-network-runner "$LOCALNET_DIR"


##############################################
# Localnet Stage
##############################################
# Final stage for localnet
FROM rust:latest as localnet
ENV DEBIAN_FRONTEND=noninteractive

# Set default values for ARGs
ARG APP_DIR="/root/movement/app"
ARG SUBNET_DIR="/root/movement/subnet"
ARG LOCALNET_DIR="/root/movement/localnet"
ARG CLI_DIR="/root/movement/cli"
ARG PLUGIN_DIR="/root/movement/plugins"
ARG SETUP_DIR="/root/movement/setup"

COPY --from=builder ${LOCALNET_DIR} ${LOCALNET_DIR}
COPY --from=builder ${PLUGIN_DIR} ${PLUGIN_DIR}

# Start runner
CMD $LOCALNET_DIR/avalanche-network-runner server --log-level debug --port=:8080 --grpc-gateway-port=:8081

##############################################
# Installer Stage
##############################################
# Final stage for installer
FROM rust:latest as installer
ENV DEBIAN_FRONTEND=noninteractive

# Set default values for ARGs
ARG APP_DIR="/root/movement/app"
ARG SUBNET_DIR="/root/movement/subnet"
ARG LOCALNET_DIR="/root/movement/localnet"
ARG CLI_DIR="/root/movement/cli"
ARG PLUGIN_DIR="/root/movement/plugins"
ARG SETUP_DIR="/root/movement/setup"

# install curl
RUN apt-get update && apt-get install -y curl

CMD curl -X POST -k http://localnet:8081/v1/control/start -d '{"execPath":"/$SUBNET_DIR/avalananche-v1.10.2/avalanchego","numNodes":5,"logLevel":"INFO","pluginDir":"${PLUGIN_DIR}","blockchainSpecs":[{"vmName":"locomotion","blockchain_alias":"locomotion"}]}'

##############################################
# Subnet Stage
##############################################
# Final stage for subnet
FROM rust:latest as subnet
ENV DEBIAN_FRONTEND=noninteractive

# Set default values for ARGs
ARG APP_DIR="/root/movement/app"
ARG SUBNET_DIR="/root/movement/subnet"
ARG LOCALNET_DIR="/root/movement/localnet"
ARG CLI_DIR="/root/movement/cli"
ARG PLUGIN_DIR="/root/movement/plugins"
ARG SETUP_DIR="/root/movement/setup"


# Copy the subnet binary from the builder image
COPY --from=builder ${SUBNET_DIR} ${SUBNET_DIR}
COPY --from=builder ${PLUGIN_DIR} ${PLUGIN_DIR}

# Set the entrypoint command
CMD $SUBNET_DIR/avalanchego-v1.10.2/avalanchego --network-id=fuji --track-subnets=2j9sL3mJrVD5KUuQAPds6m9VvTgwYCuxbtTi7WCt3nLD8dPwQe --plugin-dir=$PLUGIN_DIR

##############################################
# Dev Stage
##############################################
# Final stage for dev
FROM rust:latest as dev
ENV DEBIAN_FRONTEND=noninteractive

# Set default values for ARGs
ARG APP_DIR="/root/movement/app"
ARG SUBNET_DIR="/root/movement/subnet"
ARG LOCALNET_DIR="/root/movement/localnet"
ARG CLI_DIR="/root/movement/cli"
ARG PLUGIN_DIR="/root/movement/plugins"
ARG SETUP_DIR="/root/movement/setup"

# Copy the subnet binary from the builder image
COPY --from=builder ${CLI_DIR}/aptos /bin/aptos
RUN ln -s /bin/aptos /bin/movement

# Initialize movement
RUN movement init --rest-url http://localnet:8080 --faucet-url http://localnet:8081

CMD ["/bin/bash"]
