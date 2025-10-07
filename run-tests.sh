#!/bin/bash

# Test runner script for local validation
# Usage: ./run-tests.sh [environment] [scope] [workers]

set -e

# Default values
ENVIRONMENT=${1:-test}
SCOPE=${2:-smoke}
WORKERS=${3:-3}

echo "🚀 Starting E2E Test Execution"
echo "Environment: $ENVIRONMENT"
echo "Scope: $SCOPE" 
echo "Workers: $WORKERS"
echo "================================"

cd automationexercise-e2e-pom

# Clean previous reports
echo "🧹 Cleaning previous reports..."
npm run clean

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm ci
fi

# Install Playwright browsers if needed
echo "🎭 Installing Playwright browsers..."
npx playwright install --with-deps

# Run tests based on scope
echo "🧪 Running tests..."
case "$SCOPE" in
    "smoke")
        cross-env NODE_ENV=$ENVIRONMENT npx playwright test tests/smoke --workers=$WORKERS
        ;;
    "regression")
        cross-env NODE_ENV=$ENVIRONMENT npx playwright test tests/regression --workers=$WORKERS
        ;;
    "basic")
        cross-env NODE_ENV=$ENVIRONMENT npx playwright test tests/basic.spec.ts --workers=$WORKERS
        ;;
    "all")
        cross-env NODE_ENV=$ENVIRONMENT npx playwright test --workers=$WORKERS
        ;;
    *)
        echo "❌ Unknown scope: $SCOPE"
        echo "Available scopes: smoke, regression, basic, all"
        exit 1
        ;;
esac

# Generate reports
echo "📊 Generating reports..."
npm run reports

echo "✅ Test execution completed!"
echo "📁 Reports available in:"
echo "  - test-reports/ (HTML report)"
echo "  - allure-report/ (Allure report)"
