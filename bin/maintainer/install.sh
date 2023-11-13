#!/bin/bash
################################################################################
# This script is intended to be run on Ubuntu ARM64.
# It assumes that Rust, Cargo, and developer dependencies are already installed.
#
# This script performs the following tasks:
# - ...
#
# Prerequisites:
# - Ubuntu ARM64 environment
# - Rust and Cargo installed
# - Developer dependencies installed
#
# Usage:
# - Run this script on Ubuntu ARM64:
#     $ ./build-movement.sh
#
# Note: Make sure to review and customize the script variables and paths 
#       according to your specific requirements before running.
#
# Author: Liam Monninger
# Version: 1.0
################################################################################
set -e

# environment variables
APP_DIR=${APP_DIR:-$HOME/movement/app}
SUBNET_DIR=${SUBNET_DIR:-$HOME/movement/subnet}
LOCALNET_DIR=${LOCALNET_DIR:-$HOME/movement/localnet}
CLI_DIR=${CLI_DIR:-$HOME/movement/cli}
PLUGIN_DIR=${PLUGIN_DIR:-$HOME/movement/plugins}
SETUP_DIR=${SETUP_DIR:-$HOME/movement/setup}

# clone repo
git clone git@github.com:movemntdev/movement-subnet.git "$APP_DIR/movement-subnet"

# Create directories if they don't exist
mkdir -p "$APP_DIR"
mkdir -p "$SUBNET_DIR"
mkdir -p "$LOCALNET_DIR"
mkdir -p "$CLI_DIR"
mkdir -p "$PLUGIN_DIR"

# Set the working directory
cd "$APP_DIR/movement-subnet/vm/aptos-vm"

# Run dev_setup.sh
chmod -R 755 ./scripts/dev_setup.sh
echo "y" | ./scripts/dev_setup.sh

### SUBNET ###
# Build subnet
cargo build -p subnet --release

# Copy the subnet binary to the plugins directory
cp "$APP_DIR/movement-subnet/vm/aptos-vm/target/release/subnet" "$PLUGIN_DIR/b6z34iYog6Qm8uUWmssHYWDhShhufDC1XEkXDQRabFWA3Ac6Y"

# Download avalanchego
curl -L -o "$SUBNET_DIR/avalanchego.tar.gz" "https://github.com/ava-labs/avalanchego/releases/download/v1.10.2/avalanchego-linux-arm64-v1.10.2.tar.gz"

# Extract avalanchego
tar -xzf "$SUBNET_DIR/avalanchego.tar.gz" -C "$SUBNET_DIR"

### CLI ###
cd "$APP_DIR/movement-subnet/vm/aptos-vm/crates/aptos"

# Build cli
cargo build --release

# Copy the cli binary to the cli directory
cp "$APP_DIR/movement-subnet/vm/aptos-vm/target/release/aptos" "$CLI_DIR"

# Add the local tesnet client
curl -sSfL https://raw.githubusercontent.com/ava-labs/avalanche-network-runner/main/scripts/install.sh | sh -s

cp $HOME/avalanche-network-runner $LOCALNET_DIR/avalanche-network-runner