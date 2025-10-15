#!/bin/bash

# Script to open downloaded Allure reports
# Usage: ./open-reports.sh [report-folder]

REPORT_FOLDER=${1:-"allure-report-test-6"}

echo "🚀 Opening Allure Report from: $REPORT_FOLDER"

# Check if folder exists
if [ ! -d "$REPORT_FOLDER" ]; then
    echo "❌ Error: Folder '$REPORT_FOLDER' not found!"
    echo "Available folders:"
    ls -d allure-report-* 2>/dev/null || echo "No allure-report folders found"
    exit 1
fi

# Check if index.html exists
if [ ! -f "$REPORT_FOLDER/index.html" ]; then
    echo "❌ Error: index.html not found in $REPORT_FOLDER"
    echo "This might not be a valid Allure report folder"
    exit 1
fi

echo "📁 Found Allure report in: $REPORT_FOLDER"

# Method 1: Try Allure CLI first
if command -v allure &> /dev/null; then
    echo "🎯 Using Allure CLI to open report..."
    allure open "$REPORT_FOLDER"
elif command -v npx &> /dev/null; then
    echo "🎯 Using npx allure to open report..."
    npx allure open "$REPORT_FOLDER"
# Method 2: Python HTTP Server
elif command -v python3 &> /dev/null; then
    echo "🐍 Using Python HTTP Server..."
    cd "$REPORT_FOLDER"
    echo "📡 Server starting at: http://localhost:8000"
    echo "🌐 Open your browser and go to: http://localhost:8000"
    echo "⏹️  Press Ctrl+C to stop the server"
    python3 -m http.server 8000
# Method 3: Node.js HTTP Server
elif command -v node &> /dev/null; then
    echo "🟢 Using Node.js HTTP Server..."
    cd "$REPORT_FOLDER"
    echo "📡 Server starting at: http://localhost:8000"
    echo "🌐 Open your browser and go to: http://localhost:8000"
    echo "⏹️  Press Ctrl+C to stop the server"
    npx http-server -p 8000
# Method 4: Fallback - try to open directly
else
    echo "⚠️  No suitable server found. Trying to open directly..."
    echo "🌐 Opening index.html in default browser..."
    
    # Try different OS commands
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        open "$REPORT_FOLDER/index.html"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        xdg-open "$REPORT_FOLDER/index.html"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        # Windows
        start "$REPORT_FOLDER/index.html"
    else
        echo "❌ Cannot automatically open the report"
        echo "📝 Manual steps:"
        echo "   1. Start a local HTTP server in the $REPORT_FOLDER directory"
        echo "   2. Open http://localhost:8000 in your browser"
    fi
fi
