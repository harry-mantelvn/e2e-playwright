#!/bin/bash

# Clean all test reports and artifacts
echo "Cleaning test reports and artifacts..."

# Remove all report directories
rm -rf test-reports
rm -rf test-results  
rm -rf single-file-reports
rm -rf playwright-report

echo "Reports cleaned successfully"
