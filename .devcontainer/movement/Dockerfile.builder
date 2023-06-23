# Base image
FROM rust:latest as builder

# Set DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

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

# Clone movement-subnet repository
RUN --mount=type=ssh git clone git@github.com:movemntdev/movement-subnet.git /app/movement-subnet

# Set the working directory
WORKDIR /app/movement-subnet/vm/aptos-vm

# Run dev_setup.sh
RUN chmod -R 755 ./scripts/dev_setup.sh # TODO: update permissions in movement-subnet repository
RUN echo "y" | ./scripts/dev_setup.sh # TODO: update dev_setup.sh to not prompt for user input or respect DEBIAN_FRONTEND

##! WE NEED TO RUN THE BUILDS OUT HERE SO THAT WE KEEP DEV SETUP
### SUBNET ###
# Build subnet
RUN cargo build -p subnet --release

# Create a directory for the subnet binary
RUN mkdir -p /subnet/plugins

# Copy the subnet binary to the plugins directory
RUN cp /app/movement-subnet/vm/aptos-vm/target/release/subnet /subnet/plugins/b6z34iYog6Qm8uUWmssHYWDhShhufDC1XEkXDQRabFWA3Ac6Y

# Download avalanchego
RUN curl -L -o /subnet/avalanchego.tar.gz https://github.com/ava-labs/avalanchego/releases/download/v1.10.2/avalanchego-linux-arm64-v1.10.2.tar.gz

# Extract avalanchego
RUN tar -xzf /subnet/avalanchego.tar.gz -C /subnet

### CLI ###
WORKDIR /app/movement-subnet/vm/aptos-vm/crates/aptos

# Build cli
RUN cargo build --release

# Create a directory for the cli binary
RUN mkdir -p /cli

# Copy the cli binary to the cli directory
RUN cp /app/movement-subnet/vm/aptos-vm/target/release/aptos /cli

FROM builder as subnet

# Copy the subnet binary from the builder image
# COPY --from=builder /subnet /subnet 
# TODO: determine whether we need files from outside of /subnet

# Set the entrypoint command
CMD ["/subnet/avalanchego-v1.10.2/avalanchego", "--network-id=fuji", "--track-subnets=2j9sL3mJrVD5KUuQAPds6m9VvTgwYCuxbtTi7WCt3nLD8dPwQe", "--plugin-dir=/subnet/plugins"]


FROM rust:latest as dev

# Copy the subnet binary from the builder image
COPY --from=builder /cli/aptos /bin/
RUN ln -s /bin/aptos /bin/movement

RUN movement --version

CMD ["/bin/bash"]