#!/bin/bash

set -e  # Exit on error

# Default values
OPENAPI_URL=""
NAMESPACE=""

# Function to show usage
usage() {
    echo "Usage: $0 --url <OpenAPI URL> --name <C# Namespace>"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --url)
            OPENAPI_URL="$2"
            shift 2
            ;;
        --name)
            NAMESPACE="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter: $1"
            usage
            ;;
    esac
done

# Validate required parameters
if [[ -z "$OPENAPI_URL" || -z "$NAMESPACE" ]]; then
    echo "Error: Both --url and --name must be provided."
    usage
fi

# File paths
OPENAPI_FILE="openapi.json"
OUTPUT_FILE="Models.cs"

if ! command -v nswag &> /dev/null; then
    echo "Installing dependancies..."
    npm install -g nswag
fi

echo "Downloading OpenAPI spec from $OPENAPI_URL..."
curl -L -o "$OPENAPI_FILE" "$OPENAPI_URL"

echo "Generating models..."
nswag openapi2csclient /input:"$OPENAPI_FILE" /output:"$OUTPUT_FILE" /namespace:"$NAMESPACE" /generateClientClasses:false /generateDtoTypes:true  > /dev/null 2>&1

echo "✅ Model generation complete: $OUTPUT_FILE"

echo "Cleaning up installed packages..."

npm uninstall -g nswag || true

# Remove downloaded OpenAPI spec
# rm -f openapi.json Models.cs

echo "✅ Cleanup complete!"

