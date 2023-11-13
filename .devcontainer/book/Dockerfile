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

# Set the working directory
WORKDIR /app