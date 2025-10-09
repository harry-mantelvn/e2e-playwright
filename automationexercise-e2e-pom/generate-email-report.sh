#!/bin/bash

# Generate Professional Email Report
# Creates a beautiful, professional HTML email report for managers

echo "Generating professional email report..."

# Read metrics if available
if [ -f "test-summary/metrics.json" ]; then
    # Extract values from JSON using grep and sed (more portable than jq)
    TOTAL_TESTS=$(grep '"total_tests"' test-summary/metrics.json | sed 's/.*: *\([0-9]*\).*/\1/')
    PASSED_TESTS=$(grep '"passed_tests"' test-summary/metrics.json | sed 's/.*: *\([0-9]*\).*/\1/')
    FAILED_TESTS=$(grep '"failed_tests"' test-summary/metrics.json | sed 's/.*: *\([0-9]*\).*/\1/')
    SKIPPED_TESTS=$(grep '"skipped_tests"' test-summary/metrics.json | sed 's/.*: *\([0-9]*\).*/\1/')
    PASS_RATE=$(grep '"pass_rate"' test-summary/metrics.json | sed 's/.*: *\([0-9]*\).*/\1/')
    FAIL_RATE=$(grep '"fail_rate"' test-summary/metrics.json | sed 's/.*: *\([0-9]*\).*/\1/')
    SMOKE_TESTS=$(grep '"smoke_tests"' test-summary/metrics.json | sed 's/.*: *\([0-9]*\).*/\1/')
    REGRESSION_TESTS=$(grep '"regression_tests"' test-summary/metrics.json | sed 's/.*: *\([0-9]*\).*/\1/')
    BASIC_TESTS=$(grep '"basic_tests"' test-summary/metrics.json | sed 's/.*: *\([0-9]*\).*/\1/')
else
    # Default values if metrics not available
    TOTAL_TESTS=0
    PASSED_TESTS=0
    FAILED_TESTS=0
    SKIPPED_TESTS=0
    PASS_RATE=0
    FAIL_RATE=0
    SMOKE_TESTS=0
    REGRESSION_TESTS=0
    BASIC_TESTS=0
fi

# Read test details if available
TEST_DETAILS_TABLE=""
if [ -f "test-summary/test-details.html" ]; then
    TEST_DETAILS_TABLE=$(cat test-summary/test-details.html)
fi

# Get current timestamp
CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S UTC')

# Set status color based on pass rate
if [ $PASS_RATE -ge 90 ]; then
    STATUS_COLOR="#4CAF50"
    STATUS_TEXT="EXCELLENT"
    STATUS_ICON=""
elif [ $PASS_RATE -ge 80 ]; then
    STATUS_COLOR="#FF9800"
    STATUS_TEXT="GOOD"
    STATUS_ICON=""
elif [ $PASS_RATE -ge 70 ]; then
    STATUS_COLOR="#FF5722"
    STATUS_TEXT="NEEDS ATTENTION"
    STATUS_ICON=""
else
    STATUS_COLOR="#F44336"
    STATUS_TEXT="CRITICAL"
    STATUS_ICON=""
fi

# Generate professional HTML email
cat > test-summary/professional-email.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E2E Test Execution Report</title>
    <style>
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            line-height: 1.6; 
            color: #333; 
            background-color: #f8f9fa; 
            margin: 0; 
            padding: 20px; 
        }
        .container { 
            max-width: 800px; 
            margin: 0 auto; 
            background: white; 
            border-radius: 8px; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.1); 
            overflow: hidden; 
        }
        .header { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
            color: white; 
            padding: 30px; 
            text-align: center; 
        }
        .header h1 { 
            margin: 0; 
            font-size: 28px; 
            font-weight: 300; 
        }
        .content { 
            padding: 30px; 
        }
        .status-banner { 
            background: $STATUS_COLOR; 
            color: white; 
            padding: 15px; 
            text-align: center; 
            font-size: 18px; 
            font-weight: bold; 
            margin: -30px -30px 20px -30px; 
        }
        .metrics-grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); 
            gap: 15px; 
            margin: 20px 0; 
        }
        .metric-card { 
            background: #f8f9fa; 
            border-left: 4px solid #667eea; 
            padding: 15px; 
            border-radius: 4px; 
        }
        .metric-value { 
            font-size: 24px; 
            font-weight: bold; 
            color: #333; 
        }
        .metric-label { 
            font-size: 12px; 
            color: #666; 
            text-transform: uppercase; 
            letter-spacing: 0.5px; 
        }
        .pass-rate { 
            color: #4CAF50; 
        }
        .fail-rate { 
            color: #F44336; 
        }
        .section { 
            margin: 25px 0; 
        }
        .section h3 { 
            color: #667eea; 
            border-bottom: 2px solid #e9ecef; 
            padding-bottom: 8px; 
            margin-bottom: 15px; 
        }
        table { 
            width: 100%; 
            border-collapse: collapse; 
            margin: 15px 0; 
        }
        th, td { 
            border: 1px solid #dee2e6; 
            padding: 12px; 
            text-align: left; 
        }
        th { 
            background-color: #f8f9fa; 
            font-weight: 600; 
            color: #495057; 
        }
        .config-table { 
            background: #f8f9fa; 
            border-radius: 4px; 
            padding: 15px; 
        }
        .config-table table { 
            margin: 0; 
            background: white; 
        }
        .quick-links { 
            background: #e3f2fd; 
            padding: 15px; 
            border-radius: 4px; 
            margin: 20px 0; 
        }
        .quick-links a { 
            color: #1976d2; 
            text-decoration: none; 
            font-weight: 500; 
        }
        .quick-links a:hover { 
            text-decoration: underline; 
        }
        .footer { 
            background: #f8f9fa; 
            padding: 20px; 
            text-align: center; 
            font-size: 12px; 
            color: #666; 
            border-top: 1px solid #e9ecef; 
        }
        .progress-bar { 
            width: 100%; 
            height: 8px; 
            background: #e9ecef; 
            border-radius: 4px; 
            overflow: hidden; 
            margin: 10px 0; 
        }
        .progress-fill { 
            height: 100%; 
            background: linear-gradient(90deg, #4CAF50 0%, #4CAF50 ${PASS_RATE}%, #F44336 ${PASS_RATE}%, #F44336 100%); 
        }
        @media (max-width: 600px) { 
            .metrics-grid { 
                grid-template-columns: 1fr 1fr; 
            } 
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>$STATUS_ICON E2E Test Execution Report</h1>
            <p>Automated Quality Assurance Report</p>
        </div>
        
        <div class="content">
            <div class="status-banner">
                Test Suite Status: $STATUS_TEXT ($PASS_RATE% Pass Rate)
            </div>
            
            <div class="section">
                <h3>Automation Test Execution Summary</h3>
                <div class="metrics-grid">
                    <div class="metric-card">
                        <div class="metric-value">$TOTAL_TESTS</div>
                        <div class="metric-label">Total Tests</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value pass-rate">$PASSED_TESTS</div>
                        <div class="metric-label">Passed ($PASS_RATE%)</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value fail-rate">$FAILED_TESTS</div>
                        <div class="metric-label">Failed ($FAIL_RATE%)</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">$SKIPPED_TESTS</div>
                        <div class="metric-label">Skipped</div>
                    </div>
                </div>
                
                <div class="progress-bar">
                    <div class="progress-fill"></div>
                </div>
            </div>
            
            <div class="section">
                <h3>Test Configuration</h3>
                <div class="config-table">
                    <table>
                        <tr><td><strong>Environment:</strong></td><td>\{{ENVIRONMENT}}</td></tr>
                        <tr><td><strong>Test Scope:</strong></td><td>\{{TEST_SCOPE}}</td></tr>
                        <tr><td><strong>Parallel Workers:</strong></td><td>\{{WORKERS}}</td></tr>
                        <tr><td><strong>Trigger:</strong></td><td>\{{TRIGGER}}</td></tr>
                        <tr><td><strong>Run Number:</strong></td><td>#\{{RUN_NUMBER}}</td></tr>
                        <tr><td><strong>Execution Time:</strong></td><td>\{{EXECUTION_TIME}}</td></tr>
                    </table>
                </div>
            </div>
            
            <div class="section">
                <h3>Test Case Breakdown</h3>
                $TEST_DETAILS_TABLE
                
                <div style="margin-top: 15px;">
                    <p><strong>Test Categories Summary:</strong></p>
                    <ul>
                        <li><strong>Smoke Tests:</strong> $SMOKE_TESTS test files (Core functionality validation)</li>
                        <li><strong>Regression Tests:</strong> $REGRESSION_TESTS test files (Full feature testing)</li>
                        <li><strong>Basic Tests:</strong> $BASIC_TESTS test files (System connectivity)</li>
                    </ul>
                </div>
            </div>
            
            <div class="section">
                <div class="quick-links">
                    <h3 style="margin-top: 0; color: #1976d2;">Quick Access Links</h3>
                    <p>
                        <a href="\{{EXECUTION_URL}}" target="_blank">View Full Execution Log</a> | 
                        <a href="\{{ARTIFACTS_URL}}" target="_blank">Download Detailed Reports</a> | 
                        <a href="\{{REPO_URL}}" target="_blank">View Source Code</a>
                    </p>
                </div>
            </div>
            
            <div class="section">
                <h3>Quality Insights</h3>
                <ul>
                    <li><strong>Test Coverage:</strong> $TOTAL_TESTS test cases across multiple user journeys</li>
                    <li><strong>Success Rate:</strong> $PASS_RATE% of tests passed successfully</li>
                    <li><strong>Risk Assessment:</strong> $(if [ $FAIL_RATE -gt 20 ]; then echo "High - Immediate attention required"; elif [ $FAIL_RATE -gt 10 ]; then echo "Medium - Review recommended"; else echo "Low - System stable"; fi)</li>
                    <li><strong>Recommendation:</strong> $(if [ $PASS_RATE -ge 90 ]; then echo "System ready for deployment"; elif [ $PASS_RATE -ge 80 ]; then echo "Minor issues to address before deployment"; else echo "Critical issues must be resolved before deployment"; fi)</li>
                </ul>
            </div>
        </div>
        
        <div class="footer">
            <p>This automated report was generated by GitHub Actions CI/CD Pipeline</p>
            <p>Report generated on: \{{EXECUTION_TIME}}</p>
            <p>For technical support, contact the QA Team</p>
        </div>
    </div>
</body>
</html>
EOF

# Convert escaped template variables back to proper template placeholders
sed -i '' 's/\\{{/{{/g' test-summary/professional-email.html

echo "Professional email report generated: test-summary/professional-email.html"
