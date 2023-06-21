FROM ubuntu:latest

# Update and install dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y pkg-config build-essential libudev-dev libssl-dev curl git

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install NVM
ENV NVM_DIR /root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
RUN . "$NVM_DIR/nvm.sh" && nvm install --lts

# Activate NVM environment and set default version
RUN echo ". $NVM_DIR/nvm.sh" >> /root/.bashrc
RUN echo "nvm use default" >> /root/.bashrc

# Install solana and add to PATH
RUN curl -sSf https://release.solana.com/v1.16.1/solana-release-x86_64-unknown-linux-gnu.tar.bz2 | tar -xj \
    && mv solana-release/bin /usr/local/bin

# Install Yarn
RUN . "$NVM_DIR/nvm.sh" && npm install -g yarn

# Install Anchor
RUN . "$NVM_DIR/nvm.sh" && cargo install --git https://github.com/coral-xyz/anchor avm --locked --force
RUN . "$NVM_DIR/nvm.sh" && avm install latest
RUN . "$NVM_DIR/nvm.sh" && avm use latest

# Set the working directory
WORKDIR /workspace

CMD ["/bin/bash"]

