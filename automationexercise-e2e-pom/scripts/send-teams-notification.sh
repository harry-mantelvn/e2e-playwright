#!/bin/bash

# Teams notification script with safe webhook URLs
# Usage: ./send-teams-notification.sh [message]

set -e

# Check for Teams webhook URL
if [ -z "$TEAMS_WEBHOOK_URL" ]; then
    echo "❌ Error: TEAMS_WEBHOOK_URL environment variable is not set"
    echo ""
    echo "Please set your Teams webhook URL:"
    echo "  export TEAMS_WEBHOOK_URL='https://your-tenant.powerplatform.com/powerautomate/automations/direct/workflows/YOUR_WORKFLOW_ID/triggers/manual/paths/invoke'"
    echo ""
    echo "For help setting up Teams webhook, see: documents/TEAMS-SETUP-GUIDE.md"
    exit 1
fi

# Default message
MESSAGE="${1:-🤖 E2E Test Automation - Default Notification}"

# Get current timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Prepare JSON payload
JSON_PAYLOAD=$(cat <<EOF
{
    "title": "E2E Test Automation",
    "text": "$MESSAGE",
    "timestamp": "$TIMESTAMP",
    "source": "Automation Framework"
}
EOF
)

echo "📤 Sending Teams notification..."
echo "Webhook: ${TEAMS_WEBHOOK_URL:0:50}..."
echo "Message: $MESSAGE"

# Send notification
RESPONSE=$(curl -s -w "%{http_code}" -X POST "$TEAMS_WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "$JSON_PAYLOAD")

HTTP_CODE="${RESPONSE: -3}"
RESPONSE_BODY="${RESPONSE%???}"

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "202" ]; then
    echo "✅ Teams notification sent successfully!"
else
    echo "❌ Failed to send Teams notification"
    echo "HTTP Code: $HTTP_CODE"
    echo "Response: $RESPONSE_BODY"
    exit 1
fi
