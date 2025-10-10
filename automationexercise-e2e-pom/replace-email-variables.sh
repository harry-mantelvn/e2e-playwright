#!/bin/bash

# Replace Template Variables in Enhanced Email Report
# This script replaces all template variables with actual GitHub Actions context values

echo "🔄 Replacing template variables in enhanced email report..."

# Set default values or read from environment
ENVIRONMENT="${ENVIRONMENT:-${INPUT_ENVIRONMENT:-test}}"
TEST_SCOPE="${TEST_SCOPE:-${INPUT_TEST_SCOPE:-smoke}}"
WORKERS="${WORKERS:-${INPUT_WORKERS:-3}}"
BROWSER="${BROWSER:-chromium}"
TRIGGER="${TRIGGER:-${GITHUB_EVENT_NAME:-manual}}"
RUN_NUMBER="${RUN_NUMBER:-${GITHUB_RUN_NUMBER:-1}}"
EXECUTION_TIME="${EXECUTION_TIME:-$(date '+%Y-%m-%d %H:%M:%S UTC')}"

# GitHub URLs
PIPELINE_URL="${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-your-org/repo}/actions/runs/${GITHUB_RUN_ID:-latest}"
ARTIFACTS_URL="${PIPELINE_URL}#artifacts"
REPO_URL="${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-your-org/repo}"

# Choose email template
EMAIL_FILE="test-summary/enhanced-email-report.html"
if [ ! -f "$EMAIL_FILE" ]; then
    EMAIL_FILE="test-summary/professional-email.html"
    echo "⚠️ Enhanced email report not found, using fallback"
else
    echo "✅ Using enhanced email report"
fi

if [ -f "$EMAIL_FILE" ]; then
    echo "📧 Processing email template: $(basename "$EMAIL_FILE")"
    
    # Read the email template
    EMAIL_BODY=$(cat "$EMAIL_FILE")
    
    # Replace all template variables
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s/{{ENVIRONMENT}}/$ENVIRONMENT/g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s/{{TEST_SCOPE}}/$TEST_SCOPE/g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s/{{WORKERS}}/$WORKERS/g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s/{{BROWSER}}/$BROWSER/g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s/{{TRIGGER}}/$TRIGGER/g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s/{{RUN_NUMBER}}/$RUN_NUMBER/g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s/{{EXECUTION_TIME}}/$EXECUTION_TIME/g")
    
    # Replace URL placeholders
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s|PIPELINE_URL_PLACEHOLDER|$PIPELINE_URL|g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s|ARTIFACTS_URL_PLACEHOLDER|$ARTIFACTS_URL|g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s|REPO_URL_PLACEHOLDER|$REPO_URL|g")
    
    # Replace legacy URL templates (for backward compatibility)
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s|{{EXECUTION_URL}}|$PIPELINE_URL|g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s|{{ARTIFACTS_URL}}|$ARTIFACTS_URL|g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s|{{REPO_URL}}|$REPO_URL|g")
    
    # Save the processed email
    echo "$EMAIL_BODY" > test-summary/final-email.html
    
    echo "✅ Template variables replaced successfully"
    echo "📊 Email template size: $(wc -c < "$EMAIL_FILE") bytes"
    echo "📧 Final email size: $(wc -c < test-summary/final-email.html) bytes"
    echo "🔗 Pipeline URL: $PIPELINE_URL"
    
else
    echo "❌ No email template found, creating minimal fallback"
    
    # Create a minimal fallback email
    cat > test-summary/final-email.html << EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>E2E Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background: #667eea; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; border: 1px solid #ddd; }
        .status { padding: 10px; margin: 10px 0; border-radius: 4px; }
        .info { background: #e3f2fd; }
        a { color: #1976d2; text-decoration: none; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🎯 E2E Test Execution Report</h1>
    </div>
    <div class="content">
        <div class="status info">
            <h3>📊 Test Execution Completed</h3>
            <p><strong>Environment:</strong> $ENVIRONMENT</p>
            <p><strong>Test Scope:</strong> $TEST_SCOPE</p>
            <p><strong>Workers:</strong> $WORKERS</p>
            <p><strong>Trigger:</strong> $TRIGGER</p>
            <p><strong>Execution Time:</strong> $EXECUTION_TIME</p>
        </div>
        
        <h3>🔗 Quick Access</h3>
        <p>
            <a href="$PIPELINE_URL" target="_blank">📊 View Pipeline Details</a> |
            <a href="$ARTIFACTS_URL" target="_blank">📁 Download Reports</a> |
            <a href="$REPO_URL" target="_blank">💻 Source Code</a>
        </p>
        
        <p><strong>Note:</strong> Please check the artifacts section for detailed test results and Allure reports.</p>
    </div>
</body>
</html>
EOF

    echo "📧 Fallback email created successfully"
fi

echo "🎯 Email template processing completed!"
echo "📁 Final email saved to: test-summary/final-email.html"
