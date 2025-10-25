#!/bin/bash
#
# build.sh
# Build script for VOICE package using Swift Package Manager
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIGURATION="${1:-debug}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Building VOICE Package${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Package Directory: ${YELLOW}${PROJECT_DIR}${NC}"
echo -e "Configuration: ${YELLOW}${CONFIGURATION}${NC}"
echo ""

# Change to project directory
cd "${PROJECT_DIR}"

# Clean build folder
echo -e "${YELLOW}Cleaning build artifacts...${NC}"
swift package clean

echo ""
echo -e "${YELLOW}Resolving dependencies...${NC}"
swift package resolve

echo ""
echo -e "${YELLOW}Building package...${NC}"

# Build
if [ "${CONFIGURATION}" == "release" ]; then
  swift build -c release
else
  swift build
fi

BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -eq 0 ]; then
  echo ""
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}✓ Build succeeded!${NC}"
  echo -e "${GREEN}========================================${NC}"
  echo ""
  echo -e "${BLUE}You can now:${NC}"
  echo -e "  ${YELLOW}•${NC} Run the CLI: ${YELLOW}swift run voice-cli${NC}"
  echo -e "  ${YELLOW}•${NC} Run tests: ${YELLOW}./Scripts/test.sh${NC}"
  echo -e "  ${YELLOW}•${NC} Open in Xcode: ${YELLOW}open VOICE/VOICE.xcodeproj${NC}"
  echo ""
  exit 0
else
  echo ""
  echo -e "${RED}========================================${NC}"
  echo -e "${RED}✗ Build failed!${NC}"
  echo -e "${RED}========================================${NC}"
  exit $BUILD_EXIT_CODE
fi

