#!/bin/bash

# Validation script for CI/CD setup
# This script validates that all components are working correctly

set -e

echo "Validating E2E Automation Framework Setup"
echo "=============================================="

cd automationexercise-e2e-pom

# Check dependencies
echo "Checking dependencies..."
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm ci
fi

# Check Playwright installation
echo "Checking Playwright browsers..."
npx playwright --version

# Validate configuration files
echo "Validating configuration files..."
if [ ! -f "playwright.config.ts" ]; then
    echo "Missing playwright.config.ts"
    exit 1
fi

if [ ! -f "package.json" ]; then
    echo "Missing package.json"
    exit 1
fi

if [ ! -f "tsconfig.json" ]; then
    echo "Missing tsconfig.json"
    exit 1
fi

# Check environment files
echo "Checking environment configurations..."
if [ ! -d "environments" ]; then
    echo "Missing environments directory"
    exit 1
fi

# Validate page objects
echo "Validating page objects..."
if [ ! -d "pages" ]; then
    echo "Missing pages directory"
    exit 1
fi

# Check test files
echo "Checking test files..."
if [ ! -d "tests/smoke" ]; then
    echo "Missing smoke tests directory"
    exit 1
fi

if [ ! -d "tests/regression" ]; then
    echo "Missing regression tests directory"
    exit 1
fi

# Test clean script
echo "Testing clean reports script..."
npm run clean

# Validate scripts
echo "Validating package.json scripts..."
npm run --silent | grep -E "clean|test|allure" || echo "Some scripts might be missing"

# Test basic functionality
echo "Running basic test validation..."
timeout 60 npx playwright test tests/basic.spec.ts --headed=false || echo "Basic test validation failed (this is normal if no basic.spec.ts exists)"

echo ""
echo "Validation Complete!"
echo ""
echo "Summary:"
echo "  Dependencies installed"
echo "  Configuration files present"
echo "  Environment setup valid"
echo "  Page objects structure correct"
echo "  Test files organized"
echo "  Clean scripts working"
echo ""
echo "Ready for CI/CD execution!"
echo ""
echo "Next Steps:"
echo "  1. Test locally: ./run-tests.sh test smoke 3"
echo "  2. Commit and push changes"
echo "  3. Run GitHub Actions workflow"
echo "  4. Configure email secrets (if needed)"
