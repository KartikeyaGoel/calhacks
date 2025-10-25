#!/bin/bash
#
# test.sh
# Test script for VOICE package using Swift Package Manager
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
PARALLEL="${1:-}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Running VOICE Tests${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Package Directory: ${YELLOW}${PROJECT_DIR}${NC}"
echo ""

# Change to project directory
cd "${PROJECT_DIR}"

# Run tests
echo -e "${YELLOW}Running tests...${NC}"
echo ""

if [ "${PARALLEL}" == "--parallel" ]; then
  swift test --parallel
else
  swift test
fi

TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -eq 0 ]; then
  echo ""
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}✓ All tests passed!${NC}"
  echo -e "${GREEN}========================================${NC}"
  echo ""
  echo -e "${BLUE}Note:${NC} Tests run using Swift Package Manager"
  echo -e "For iOS UI testing, use Xcode: ${YELLOW}open VOICE/VOICE.xcodeproj${NC}"
  echo ""
  exit 0
else
  echo ""
  echo -e "${RED}========================================${NC}"
  echo -e "${RED}✗ Tests failed!${NC}"
  echo -e "${RED}========================================${NC}"
  exit $TEST_EXIT_CODE
fi

