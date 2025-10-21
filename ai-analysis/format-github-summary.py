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
        
        # Handle both old and new format
        summary = data.get('summary', data.get('executive_summary', {}))
        metadata = data.get('analysis_metadata', {})
        
        # Try to get total tests from multiple possible locations
        total_tests = summary.get('total_tests', 0)
        if total_tests == 0 and 'stats' in data:
            total_tests = data['stats'].get('expected', 0) + data['stats'].get('unexpected', 0)
        
        passed_tests = summary.get('passed_tests', 0)
        if passed_tests == 0 and 'stats' in data:
            passed_tests = data['stats'].get('expected', 0)
        
        total_failures = summary.get('total_failures', 0)
        if total_failures == 0 and 'stats' in data:
            total_failures = data['stats'].get('unexpected', 0)
        
        pass_rate = summary.get('pass_rate', 0)
        if pass_rate == 0 and total_tests > 0:
            pass_rate = (passed_tests / total_tests) * 100 if total_tests > 0 else 0
        
        # Executive Summary
        print("### 📊 Executive Summary")
        print("")
        print(f"- **Total Tests**: {total_tests}")
        print(f"- **Passed**: ✅ {passed_tests}")
        print(f"- **Failed**: ❌ {total_failures}")
        print(f"- **Pass Rate**: {pass_rate:.1f}%")
        
        engine = metadata.get('analysis_engine', metadata.get('ai_provider', 'unknown'))
        print(f"- **Analysis Engine**: {engine}")
        print("")
        
        # Failed tests list
        if total_failures > 0:
            # Get failed tests from multiple possible locations
            failed_test_names = summary.get('failed_tests', [])
            if not failed_test_names and 'failures' in data:
                failed_test_names = [f.get('test_name', f.get('title', 'Unknown')) 
                                    for f in data['failures']]
            
            if failed_test_names:
                print("### ❌ Failed Tests")
                print("")
                for test in failed_test_names:
                    print(f"- `{test}`")
                print("")
            
            # Detailed failures - try multiple locations
            failures = data.get('failures', data.get('detailed_analysis', data.get('test_failures', [])))
            
            if failures:
                print("### 🔍 Detailed Failure Analysis")
                print("")
                for i, failure in enumerate(failures[:5], 1):  # Show top 5
                    test_name = failure.get('test_name', failure.get('test_title', failure.get('title', 'Unknown')))
                    print(f"#### {i}. {test_name}")
                    print("")
                    
                    file_path = failure.get('file', 'Unknown')
                    print(f"**File**: `{file_path}`")
                    
                    # Get analysis from multiple possible locations
                    analysis = failure.get('analysis', failure)
                    root_cause = analysis.get('root_cause', 'Unknown')
                    category = analysis.get('category', 'Unknown')
                    severity = analysis.get('severity', 'Unknown')
                    
                    print(f"**Root Cause**: {root_cause}")
                    print(f"**Category**: {category}")
                    print(f"**Severity**: {severity}")
                    print("")
                    
                    # Recommendations
                    recs = analysis.get('recommendations', analysis.get('actionable_steps', []))
                    if recs:
                        print("**Recommendations**:")
                        for rec in recs[:3]:
                            rec_text = rec if isinstance(rec, str) else rec.get('action', rec.get('text', 'N/A'))
                            print(f"- {rec_text}")
                    
                    # Code example if available
                    code_example = analysis.get('code_example', analysis.get('fix_example', ''))
                    if code_example:
                        print("")
                        print("**Code Example**:")
                        print("```typescript")
                        print(code_example)
                        print("```")
                    
                    print("")
                
                if len(failures) > 5:
                    print(f"*... and {len(failures) - 5} more failures. See full report in artifacts.*")
                    print("")
        else:
            print("### ✅ All Tests Passed!")
            print("")
            print("No failures detected. Great job! 🎉")
            print("")
        
        # Executive summary text
        exec_summary_text = data.get('executive_summary')
        if isinstance(exec_summary_text, str):
            print("### 💡 Executive Summary")
            print("")
            print(exec_summary_text)
            print("")
        elif isinstance(exec_summary_text, dict) and 'message' in exec_summary_text:
            print("### 💡 Key Message")
            print("")
            print(exec_summary_text['message'])
            print("")
        
        # Next steps
        next_steps = data.get('next_steps', data.get('actionable_recommendations', []))
        if next_steps:
            print("### 🎯 Recommended Next Steps")
            print("")
            for step in next_steps[:5]:
                step_text = step if isinstance(step, str) else step.get('action', step.get('text', 'N/A'))
                print(f"- {step_text}")
            print("")
        
    except Exception as e:
        print(f"❌ Error parsing analysis: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    analysis_file = sys.argv[1] if len(sys.argv) > 1 else 'analysis-output.json'
    format_analysis_summary(analysis_file)
