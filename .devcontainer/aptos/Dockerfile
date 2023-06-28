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

# Clone aptos-core repository
RUN git clone https://github.com/aptos-labs/aptos-core /aptos-core

# Build cli
WORKDIR /aptos-core/crates/aptos

RUN cargo build

FROM rust:latest as localnet

COPY --from=builder /aptos-core /aptos-core

WORKDIR /aptos-core

CMD ["cargo", "run", "-p", "aptos", "--", "node", "run-local-testnet", "--with-faucet", "--faucet-port", "8081", "--force-restart", "--assume-yes"]

FROM rust:latest as dev

COPY --from=builder /aptos-core/target/debug/aptos /bin/aptos

# Initialize aptos
RUN aptos init --rest-url http://localnet:8080 --faucet-url http://localnet:8081

# Allow user to attach to bash shell
CMD ["/bin/bash"]
