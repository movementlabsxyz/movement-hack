FROM ubuntu:latest

# Update the package manager and install necessary dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    unzip

# Install nvm (Node Version Manager)
ENV NVM_DIR /root/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
RUN . $NVM_DIR/nvm.sh && nvm install node

# Install Buidler (previously foundry)
RUN curl -L https://foundry.paradigm.xyz | bash

# Install Cast CLI
RUN npm install -g cast-cli

# Set up a non-root user with sudo access for development
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID --shell /bin/bash $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME

# Set the working directory for your project
WORKDIR /app

# Set the default command to /bin/bash
CMD ["/bin/bash"]

