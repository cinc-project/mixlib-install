#!/bin/bash

#
# Script to generate Cinc install scripts using mixlib-install
#
# Usage: ./generate_install_scripts.sh [options]
#
# Options:
#   -b, --base-url URL     - Base URL for package downloads (optional)
#   -p, --product NAME     - Product name (default: cinc)
#   -c, --channel NAME     - Channel (default: stable)
#   -v, --version VER      - Product version (default: latest)
#   -o, --output DIR       - Output directory (default: current directory)
#   -h, --help             - Show this help message
#

set -e

# Default values
PRODUCT_NAME="cinc"
CHANNEL="stable"
VERSION="latest"
OUTPUT_DIR="."
BASE_URL=""

# Parse command line arguments
show_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -b, --base-url URL     Base URL for package downloads (optional)"
    echo "  -p, --product NAME     Product name (default: cinc)"
    echo "  -c, --channel NAME     Channel: stable, current, or unstable (default: stable)"
    echo "  -v, --version VER      Product version (default: latest)"
    echo "  -o, --output DIR       Output directory (default: current directory)"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -p cinc-workstation -v 24.2.1058"
    echo "  $0 -o /tmp/scripts -c current"
    echo "  $0 -b https://custom-repo.example.com"
    exit 0
}

# Check if help is requested
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_usage
fi

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--base-url)
            BASE_URL="$2"
            shift 2
            ;;
        -p|--product)
            PRODUCT_NAME="$2"
            shift 2
            ;;
        -c|--channel)
            CHANNEL="$2"
            shift 2
            ;;
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            ;;
        *)
            echo "Error: Unknown option: $1"
            show_usage
            ;;
    esac
done

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check if mixlib-install gem is installed
echo "Checking for mixlib-install gem..."
if ! gem list -i mixlib-install > /dev/null 2>&1; then
    echo "mixlib-install gem not found. Installing..."
    gem build mixlib-install.gemspec
    gem install mixlib-install-*.gem
    echo "mixlib-install gem installed successfully"
else
    echo "mixlib-install gem is already installed"
fi

# Generate install.sh script for Linux/Unix
echo ""
echo "Generating install.sh for $PRODUCT_NAME (channel: $CHANNEL, version: $VERSION)..."

ruby -I "lib" -e "
require 'mixlib/install'

context = {}
context[:base_url] = '$BASE_URL' unless '$BASE_URL'.empty?

script = Mixlib::Install.install_sh(context)

File.write('$OUTPUT_DIR/install.sh', script)
puts 'install.sh generated successfully'
"

# Make the script executable
chmod +x "$OUTPUT_DIR/install.sh"

# Generate install.ps1 script for Windows
echo ""
echo "Generating install.ps1 for $PRODUCT_NAME (channel: $CHANNEL, version: $VERSION)..."

ruby -I "lib" -e "
require 'mixlib/install'

context = {}
context[:base_url] = '$BASE_URL' unless '$BASE_URL'.empty?

script = Mixlib::Install.install_ps1(context)

File.write('$OUTPUT_DIR/install.ps1', script)
puts 'install.ps1 generated successfully'
"

# Summary
echo ""
echo "================================================"
echo "Scripts generated successfully!"
echo "================================================"
echo "Product:       $PRODUCT_NAME"
echo "Channel:       $CHANNEL"
echo "Version:       $VERSION"
if [ -n "$BASE_URL" ]; then
    echo "Base URL:      $BASE_URL"
fi
echo ""
echo "Output files:"
echo "  - $OUTPUT_DIR/install.sh"
echo "  - $OUTPUT_DIR/install.ps1"
echo ""
echo "You can now use these scripts to install $PRODUCT_NAME on Linux/Unix and Windows systems."
