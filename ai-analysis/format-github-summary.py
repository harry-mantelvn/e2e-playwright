#!/usr/bin/env python3
"""
Format AI analysis output for GitHub Actions summary
"""
import json
import sys

def format_analysis_summary(analysis_file='analysis-output.json'):
    """Format analysis output as markdown for GitHub Actions"""
    try:
        with open(analysis_file) as f:
            data = json.load(f)
        
        summary = data.get('summary', {})
        metadata = data.get('analysis_metadata', {})
        
        # Executive Summary
        print("### 📊 Executive Summary")
        print("")
        print(f"- **Total Tests**: {summary.get('total_tests', 0)}")
        print(f"- **Passed**: ✅ {summary.get('passed_tests', 0)}")
        print(f"- **Failed**: ❌ {summary.get('total_failures', 0)}")
        print(f"- **Pass Rate**: {summary.get('pass_rate', 0):.1f}%")
        print(f"- **Analysis Engine**: {metadata.get('analysis_engine', 'unknown')}")
        print("")
        
        # Failed tests list
        if summary.get('total_failures', 0) > 0:
            print("### ❌ Failed Tests")
            print("")
            for test in summary.get('failed_tests', []):
                print(f"- `{test}`")
            print("")
            
            # Detailed failures
            failures = data.get('failures', [])
            if failures:
                print("### 🔍 Detailed Failure Analysis")
                print("")
                for i, failure in enumerate(failures[:5], 1):  # Show top 5
                    print(f"#### {i}. {failure['test_name']}")
                    print("")
                    print(f"**File**: `{failure['file']}`")
                    
                    analysis = failure.get('analysis', {})
                    print(f"**Root Cause**: {analysis.get('root_cause', 'Unknown')}")
                    print(f"**Category**: {analysis.get('category', 'Unknown')}")
                    print(f"**Severity**: {analysis.get('severity', 'Unknown')}")
                    print("")
                    
                    # Recommendations
                    recs = analysis.get('recommendations', [])
                    if recs:
                        print("**Recommendations**:")
                        for rec in recs[:3]:
                            print(f"- {rec}")
                    print("")
                
                if len(failures) > 5:
                    print(f"*... and {len(failures) - 5} more failures. See full report in artifacts.*")
        else:
            print("### ✅ All Tests Passed!")
            print("")
            print("No failures detected. Great job! 🎉")
        
        # Executive summary text
        exec_summary = data.get('executive_summary', '')
        if exec_summary:
            print("")
            print("### 💡 Executive Summary")
            print("")
            print(exec_summary)
        
        # Next steps
        next_steps = data.get('next_steps', [])
        if next_steps:
            print("")
            print("### 🎯 Recommended Next Steps")
            print("")
            for step in next_steps:
                print(f"- {step}")
        
    except Exception as e:
        print(f"❌ Error parsing analysis: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    analysis_file = sys.argv[1] if len(sys.argv) > 1 else 'analysis-output.json'
    format_analysis_summary(analysis_file)
