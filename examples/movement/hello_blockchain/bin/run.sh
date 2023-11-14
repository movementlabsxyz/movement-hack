#!/bin/bash -e

# Function to echo text as cyan with emoji
function begin() {
  echo -e "🔹 \033[36m$1\033[0m"
}

# Function to echo text as green with increased font-weight and emoji
function finish() {
  echo -e "✅ \033[1;32m$1\033[0m"
}

begin "Funding account for hello_blockchain deployment and call..."
movement account fund-with-faucet --account default #? does the same as the below
# movement faucet #? does the same as the above
finish "Funded account for hello_blockchain deployment and call!"

begin "Compiling hello_blockchain module..."
echo "y" | movement move compile --named-addresses hello_blockchain=default
finish "Compiled hello_blockchain module!"

begin "Publishing hello_blockchain module..."
echo "y" | movement move publish --named-addresses hello_blockchain=default
finish "Published hello_blockchain module!"

begin "Setting hello_blockchain message to 'hello!'..."
echo "y" | movement move run --function-id default::message::set_message --args string:hello!
finish "Set hello_blockchain message to 'hello'!"

begin "Querying resources for account..."
movement account list --query resources --account default
finish "Queried resources for account!"

begin "Setting hello_blockchain message to 'goodbye!'..."
echo "y" | movement move run --function-id default::message::set_message --args string:goodbye!
finish "Set hello_blockchain message to 'goodbye'!"

begin "Querying resources for account..."
movement account list --query resources --account default
finish "Queried resources for account!"