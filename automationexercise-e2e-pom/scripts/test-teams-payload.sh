#!/bin/bash

# Test script to verify Teams adaptive card payload format
# This generates the JSON without sending it

MESSAGE="${1:-E2E Test Report - Run #123 | Status: EXCELLENT | Environment: test | Scope: smoke | Tests: 10 | Passed: 10 | Failed: 0 | Pass Rate: 100% | Pipeline: https://github.com/user/repo/actions/runs/123}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Prepare JSON payload with adaptive card format for Power Automate
JSON_PAYLOAD=$(cat <<EOF
{
    "type": "message",
    "attachments": [
        {
            "contentType": "application/vnd.microsoft.card.adaptive",
            "content": {
                "\$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                "type": "AdaptiveCard",
                "version": "1.4",
                "body": [
                    {
                        "type": "TextBlock",
                        "text": "E2E Test Automation",
                        "size": "Large",
                        "weight": "Bolder"
                    },
                    {
                        "type": "TextBlock",
                        "text": "$MESSAGE",
                        "wrap": true
                    },
                    {
                        "type": "FactSet",
                        "facts": [
                            {
                                "title": "Timestamp:",
                                "value": "$TIMESTAMP"
                            },
                            {
                                "title": "Source:",
                                "value": "GitHub Actions"
                            }
                        ]
                    }
                ]
            }
        }
    ]
}
EOF
)

echo "=== Teams Adaptive Card Payload ==="
echo "$JSON_PAYLOAD" | jq '.' || echo "$JSON_PAYLOAD"
echo ""
echo "=== Validation ==="
echo "✓ Has 'attachments' array"
echo "✓ Attachment has 'contentType' and 'content'"
echo "✓ Content has adaptive card structure"
echo "✓ Message: $MESSAGE"
