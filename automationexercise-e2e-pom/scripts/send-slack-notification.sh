#!/bin/bash

# Slack notification script with safe webhook URLs
# Usage: ./send-slack-notification.sh [message]

set -e

# Check for Slack webhook URL
if [ -z "$SLACK_WEBHOOK_URL" ]; then
    echo "❌ Error: SLACK_WEBHOOK_URL environment variable is not set"
    echo ""
    echo "Please set your Slack webhook URL:"
    echo "  export SLACK_WEBHOOK_URL='https://hooks.slack.com/services/YOUR/WEBHOOK/URL'"
    echo ""
    echo "For help setting up Slack webhook, see Slack documentation"
    exit 1
fi

# Default message
MESSAGE="${1:-🤖 E2E Test Automation - Default Notification}"

# Get current timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Prepare JSON payload for Slack
JSON_PAYLOAD=$(cat <<EOF
{
    "text": "E2E Test Automation Notification",
    "blocks": [
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": "E2E Test Automation"
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "$MESSAGE"
            }
        },
        {
            "type": "context",
            "elements": [
                {
                    "type": "mrkdwn",
                    "text": "*Timestamp:* $TIMESTAMP | *Source:* GitHub Actions"
                }
            ]
        }
    ]
}
EOF
)

echo "📤 Sending Slack notification..."
echo "Webhook: ${SLACK_WEBHOOK_URL:0:50}..."
echo "Message: $MESSAGE"

# Send notification
RESPONSE=$(curl -s -w "%{http_code}" -X POST "$SLACK_WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "$JSON_PAYLOAD")

HTTP_CODE="${RESPONSE: -3}"
RESPONSE_BODY="${RESPONSE%???}"

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "202" ]; then
    echo "✅ Slack notification sent successfully!"
else
    echo "❌ Failed to send Slack notification"
    echo "HTTP Code: $HTTP_CODE"
    echo "Response: $RESPONSE_BODY"
    exit 1
fi
