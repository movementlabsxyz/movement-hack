# Base image
FROM rust:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    pkg-config \
    libudev-dev

# Install mdBook
RUN cargo install mdbook

# Install Move CLI
RUN cargo install --git https://github.com/move-language/move move-cli --branch main

# Set the working directory
WORKDIR /app

# Set the entrypoint command
CMD ["move", "--version"]