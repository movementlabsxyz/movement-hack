FROM mvlbs/m1

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    pkg-config \
    libudev-dev

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# Set the PATH for cargo
ENV PATH="/root/.cargo/bin:${PATH}"

# Install mdBook
RUN cargo install mdbook

# Install move-analyzer
RUN cargo install --git https://github.com/move-language/move move-analyzer