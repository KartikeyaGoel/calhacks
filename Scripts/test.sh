#!/bin/bash
#
# test.sh
# Test script for VOICE app
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

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Running VOICE Tests${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Project: ${YELLOW}${PROJECT_PATH}${NC}"
echo -e "Scheme: ${YELLOW}${SCHEME}${NC}"
echo -e "Destination: ${YELLOW}${DESTINATION}${NC}"
echo ""

# Run tests
echo -e "${YELLOW}Running tests...${NC}"

xcodebuild test \
  -project "${PROJECT_PATH}" \
  -scheme "${SCHEME}" \
  -destination "${DESTINATION}" \
  -derivedDataPath "${PROJECT_DIR}/DerivedData" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  | xcpretty || true

TEST_EXIT_CODE=${PIPESTATUS[0]}

if [ $TEST_EXIT_CODE -eq 0 ]; then
  echo ""
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}✓ All tests passed!${NC}"
  echo -e "${GREEN}========================================${NC}"
  exit 0
else
  echo ""
  echo -e "${RED}========================================${NC}"
  echo -e "${RED}✗ Tests failed!${NC}"
  echo -e "${RED}========================================${NC}"
  exit $TEST_EXIT_CODE
fi

