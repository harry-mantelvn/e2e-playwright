#!/usr/bin/env python3
"""
Convert test-summary/metrics.json to Playwright JSON format
for AI analysis
"""
import json
import sys
from pathlib import Path

def convert_metrics_to_playwright(metrics_file, output_file):
    """Convert metrics.json to Playwright test results format"""
    try:
        with open(metrics_file) as f:
            metrics = json.load(f)
        
        # Extract test information
        total_tests = metrics.get('total_test_cases', 0)
        passed = metrics.get('passed_tests', 0)
        failed = metrics.get('failed_tests', 0)
        
        # Create Playwright-compatible JSON structure
        playwright_json = {
            "suites": [],
            "stats": {
                "expected": passed,
                "unexpected": failed,
                "flaky": 0,
                "skipped": 0
            },
            "config": {
                "workers": 3
            }
        }
        
        # Try to extract failure details if available
        if failed > 0 and 'failed_test_details' in metrics:
            for detail in metrics['failed_test_details']:
                suite = {
                    "specs": [{
                        "file": detail.get('file', 'unknown.spec.ts'),
                        "tests": [{
                            "title": detail.get('name', 'Unknown test'),
                            "results": [{
                                "status": "failed",
                                "duration": detail.get('duration', 0),
                                "error": {
                                    "message": detail.get('error', 'Test failed')
                                }
                            }]
                        }]
                    }]
                }
                playwright_json["suites"].append(suite)
        
        # Write output
        with open(output_file, 'w') as f:
            json.dump(playwright_json, f, indent=2)
        
        print(f"✅ Converted metrics to Playwright format")
        print(f"   Total tests: {total_tests}")
        print(f"   Passed: {passed}")
        print(f"   Failed: {failed}")
        return True
        
    except Exception as e:
        print(f"❌ Error converting metrics: {e}")
        return False

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: python3 convert-metrics.py <metrics.json> <output.json>")
        sys.exit(1)
    
    metrics_file = sys.argv[1]
    output_file = sys.argv[2]
    
    if not Path(metrics_file).exists():
        print(f"❌ Metrics file not found: {metrics_file}")
        sys.exit(1)
    
    success = convert_metrics_to_playwright(metrics_file, output_file)
    sys.exit(0 if success else 1)
