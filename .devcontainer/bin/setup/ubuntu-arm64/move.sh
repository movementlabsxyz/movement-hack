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
#     $ ./move.sh
#
# Note: Make sure to review and customize the script variables and paths 
#       according to your specific requirements before running.
#
# Author: Liam Monninger
# Version: 1.0
################################################################################

# Install Move CLI
cargo install --git https://github.com/move-language/move move-cli --branch main