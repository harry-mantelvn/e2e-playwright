#!/bin/bash

# Test Email Workflow Steps
# This simulates what the GitHub Actions workflow will do

echo "Testing email workflow steps..."

# Step 1: Generate email report
echo "Step 1: Generating email report..."
./generate-email-report.sh

# Step 2: Process template variables (like the workflow does)
echo "Step 2: Processing template variables..."
if [ -f "test-summary/professional-email.html" ]; then
    EMAIL_BODY=$(cat test-summary/professional-email.html)
    # Replace template variables
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s/{{ENVIRONMENT}}/test/g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s/{{TEST_SCOPE}}/smoke/g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s/{{WORKERS}}/3/g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s/{{TRIGGER}}/manual/g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s/{{RUN_NUMBER}}/123/g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s/{{EXECUTION_TIME}}/$(date '+%Y-%m-%d %H:%M:%S UTC')/g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s|{{EXECUTION_URL}}|https://github.com/example/repo/actions/runs/123|g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s|{{ARTIFACTS_URL}}|https://github.com/example/repo/actions/runs/123#artifacts|g")
    EMAIL_BODY=$(echo "$EMAIL_BODY" | sed "s|{{REPO_URL}}|https://github.com/example/repo|g")
    
    # Save the final email body
    echo "$EMAIL_BODY" > test-summary/final-email.html
    echo "Professional email report prepared successfully"
    
    # Verify substitution worked
    echo "Step 3: Verifying variable substitution..."
    if grep -q "{{" test-summary/final-email.html; then
        echo "WARNING: Some template variables were not replaced!"
        grep "{{" test-summary/final-email.html
    else
        echo "SUCCESS: All template variables were replaced"
    fi
    
    # Show sample of final email
    echo "Step 4: Sample of final email content:"
    grep -A 3 -B 3 "Environment:" test-summary/final-email.html
    
else
    echo "ERROR: Professional email template not found"
    exit 1
fi

echo "Email workflow test completed!"
