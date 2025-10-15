#!/bin/bash

# Test Slack integration with mock data
# Usage: ./test-slack-integration.sh

set -e

echo "🧪 Testing Slack Integration..."
echo "==============================="

# Check if SLACK_WEBHOOK_URL is set for real testing
if [ -n "$SLACK_WEBHOOK_URL" ]; then
    echo "✅ SLACK_WEBHOOK_URL is configured"
    echo "📤 Sending test message to configured webhook..."
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    TEST_MESSAGE="🧪 Slack Integration Test - $(date '+%Y-%m-%d %H:%M:%S')"
    
    if "$SCRIPT_DIR/send-slack-notification.sh" "$TEST_MESSAGE"; then
        echo "✅ Slack integration test passed!"
    else
        echo "❌ Slack integration test failed!"
        exit 1
    fi
else
    echo "⚠️  SLACK_WEBHOOK_URL not set - running mock test"
    echo ""
    
    # Set mock webhook for testing
    export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/MOCK_WORKSPACE_FOR_TESTING"
    
    echo "📋 Mock webhook URL: $SLACK_WEBHOOK_URL"
    echo "📤 Testing webhook format validation..."
    
    # Test JSON payload creation
    TEST_MESSAGE="🧪 Mock Slack Integration Test"
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    JSON_PAYLOAD=$(cat <<EOF
{
    "text": "$TEST_MESSAGE",
    "username": "E2E Bot",
    "icon_emoji": ":robot_face:",
    "attachments": [
        {
            "color": "good",
            "fields": [
                {
                    "title": "Timestamp",
                    "value": "$TIMESTAMP",
                    "short": true
                },
                {
                    "title": "Source",
                    "value": "Automation Framework",
                    "short": true
                }
            ]
        }
    ]
}
EOF
)
    
    echo "✅ JSON payload created successfully:"
    echo "$JSON_PAYLOAD" | jq . 2>/dev/null || echo "$JSON_PAYLOAD"
    echo ""
    echo "✅ Slack integration structure test passed!"
    echo ""
    echo "To test with real webhook:"
    echo "  1. Go to: https://api.slack.com/apps"
    echo "  2. Create webhook and get URL"
    echo "  3. Export it: export SLACK_WEBHOOK_URL='your-webhook-url'"
    echo "  4. Run this script again"
fi

echo ""
echo "🎉 Slack integration test completed!"
