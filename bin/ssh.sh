#!/bin/bash

# Copy the entire .ssh directory from host to the current directory
cp -r $HOME/.ssh .

# Set permissions for the copied .ssh directory
chmod 700 .ssh

# Set permissions for *.pub files inside .ssh directory
find .ssh -name '*.pub' -type f -exec chmod 644 {} +

# Set permissions for all other files inside .ssh directory
find .ssh -type f ! -name '*.pub' -exec chmod 600 {} +