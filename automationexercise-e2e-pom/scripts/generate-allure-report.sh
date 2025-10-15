#!/bin/bash

# Allure Report Generation Script
# This script handles Allure report generation with fallbacks

echo "Starting Allure report generation..."

# Create necessary directories
mkdir -p single-file-reports
mkdir -p test-reports/allure-results

# Check if allure-results directory has any files
if [ "$(ls -A test-reports/allure-results 2>/dev/null)" ]; then
    echo "Found test results, generating Allure report..."
    
    # Try the new Allure CLI syntax first
    if npx allure generate test-reports/allure-results --output single-file-reports; then
        echo "Allure report generated successfully!"
    elif npx allure generate test-reports/allure-results -o single-file-reports; then
        echo "Allure report generated with legacy syntax!"
    else
        echo "Allure generation failed, creating fallback report..."
        cat > single-file-reports/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Test Results</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .error { color: #d32f2f; background: #ffebee; padding: 10px; border-radius: 4px; }
        .info { color: #1976d2; background: #e3f2fd; padding: 10px; border-radius: 4px; }
    </style>
</head>
<body>
    <h1>Test Execution Results</h1>
    <div class="error">
        <h2>Allure Report Generation Failed</h2>
        <p>The Allure report could not be generated. This might be due to:</p>
        <ul>
            <li>Incompatible Allure CLI version</li>
            <li>Missing or invalid test results</li>
            <li>Configuration issues</li>
        </ul>
    </div>
    <div class="info">
        <h2>Alternative Options</h2>
        <p>Check the following locations for test results:</p>
        <ul>
            <li><strong>Playwright HTML Report:</strong> test-reports/html/index.html</li>
            <li><strong>Raw Test Results:</strong> test-results/ directory</li>
            <li><strong>Test Logs:</strong> Check CI/CD pipeline logs</li>
        </ul>
    </div>
    <p><em>Generated at: $(date)</em></p>
</body>
</html>
EOF
        echo "Fallback HTML report created"
    fi
else
    echo "No test results found in test-reports/allure-results"
    echo "Creating placeholder report..."
    cat > single-file-reports/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>No Test Results</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .warning { color: #f57c00; background: #fff3e0; padding: 10px; border-radius: 4px; }
    </style>
</head>
<body>
    <h1>Test Results</h1>
    <div class="warning">
        <h2>No Test Results Found</h2>
        <p>No test results were found in the allure-results directory.</p>
        <p>This might mean:</p>
        <ul>
            <li>Tests were not executed</li>
            <li>Tests failed to generate results</li>
            <li>Wrong directory path</li>
        </ul>
    </div>
    <p><em>Generated at: $(date)</em></p>
</body>
</html>
EOF
fi

echo "Report generation process completed."
