#!/bin/bash
#
# build.sh
# Build script for VOICE app with different environments
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="${PROJECT_DIR}/VOICE/VOICE.xcodeproj"
SCHEME="${1:-VOICE-Dev}"
DESTINATION="${2:-platform=iOS Simulator,name=iPhone 15}"
CONFIGURATION="${3:-Debug}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Building VOICE iOS App${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Project: ${YELLOW}${PROJECT_PATH}${NC}"
echo -e "Scheme: ${YELLOW}${SCHEME}${NC}"
echo -e "Configuration: ${YELLOW}${CONFIGURATION}${NC}"
echo -e "Destination: ${YELLOW}${DESTINATION}${NC}"
echo ""

# Clean build folder
echo -e "${YELLOW}Cleaning build folder...${NC}"
xcodebuild clean \
  -project "${PROJECT_PATH}" \
  -scheme "${SCHEME}" \
  -configuration "${CONFIGURATION}"

echo ""
echo -e "${YELLOW}Building project...${NC}"

# Build
xcodebuild build \
  -project "${PROJECT_PATH}" \
  -scheme "${SCHEME}" \
  -configuration "${CONFIGURATION}" \
  -destination "${DESTINATION}" \
  -derivedDataPath "${PROJECT_DIR}/DerivedData" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  | xcpretty || true

BUILD_EXIT_CODE=${PIPESTATUS[0]}

if [ $BUILD_EXIT_CODE -eq 0 ]; then
  echo ""
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}✓ Build succeeded!${NC}"
  echo -e "${GREEN}========================================${NC}"
  exit 0
else
  echo ""
  echo -e "${RED}========================================${NC}"
  echo -e "${RED}✗ Build failed!${NC}"
  echo -e "${RED}========================================${NC}"
  exit $BUILD_EXIT_CODE
fi

