#!/bin/bash -e

# builds partial docker files into a full docker files

function compile() {
    # Output file for the combined Dockerfile
    OUTPUT_FILE="$1"
    
    # Specify the Dockerfiles to concatenate
    DOCKERFILES=("${@:2}")

    echo "Compiling Dockerfiles ${DOCKERFILES[*]} to $OUTPUT_FILE..."

    # Clear the output file if it already exists
    echo "" > "$OUTPUT_FILE"

    # Concatenate the Dockerfiles into the output file
    for DOCKERFILE in "${DOCKERFILES[@]}"; do
        echo "# Dockerfile: $DOCKERFILE" >> "$OUTPUT_FILE"
        cat "$DOCKERFILE" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    done

    echo "Compiled Dockerfile $OUTPUT_FILE"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
CONTAINERS_DIR="$SCRIPT_DIR/../"

# 