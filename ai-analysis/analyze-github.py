#!/usr/bin/env python3
"""
AI Test Analysis using GitHub Copilot/Models API
Uses GITHUB_TOKEN (free, no API key needed)
"""

import json
import sys
import os
from datetime import datetime
from pathlib import Path

def load_test_results(json_path):
    """Load Playwright test results from JSON"""
    try:
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            
        # Debug: Print what we loaded
        print(f"📋 Loaded test results:", file=sys.stderr)
        print(f"   - Suites: {len(data.get('suites', []))}", file=sys.stderr)
        
        # Count total tests and failures
        total_tests = 0
        failed_tests = 0
        for suite in data.get('suites', []):
            for spec in suite.get('specs', []):
                for test in spec.get('tests', []):
                    total_tests += 1
                    for result in test.get('results', []):
                        if result.get('status') in ['failed', 'timedOut']:
                            failed_tests += 1
        
        print(f"   - Total tests: {total_tests}", file=sys.stderr)
        print(f"   - Failed tests: {failed_tests}", file=sys.stderr)
        
        return data
    except FileNotFoundError:
        print(f"❌ Error: Test results file not found: {json_path}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"❌ Error: Invalid JSON in {json_path}: {e}", file=sys.stderr)
        sys.exit(1)

def analyze_with_github_models(test_results, github_token):
    """
    Analyze test results using GitHub Copilot/Models API
    Uses free tier with GITHUB_TOKEN
    """
    try:
        import requests
        
        # Prepare analysis prompt
        failures = []
        for suite in test_results.get('suites', []):
            for spec in suite.get('specs', []):
                for test in spec.get('tests', []):
                    for result in test.get('results', []):
                        status = result.get('status', '')
                        if status in ['failed', 'timedOut']:
                            # Extract error message properly
                            error_obj = result.get('error', {})
                            error_msg = 'No error message'
                            
                            if isinstance(error_obj, dict):
                                error_msg = error_obj.get('message', error_obj.get('value', 'No error message'))
                            elif isinstance(error_obj, str):
                                error_msg = error_obj
                            
                            failures.append({
                                'title': test.get('title', 'Unknown'),
                                'file': spec.get('file', 'Unknown'),
                                'error': error_msg,
                                'duration': result.get('duration', 0),
                                'status': status
                            })
        
        print(f"🔍 Found {len(failures)} failures to analyze", file=sys.stderr)
        
        if not failures:
            return {
                "analysis_metadata": {
                    "timestamp": datetime.utcnow().isoformat() + "Z",
                    "status": "success",
                    "ai_provider": "github-copilot",
                    "model": "gpt-4o",
                    "version": "2.0"
                },
                "executive_summary": {
                    "total_failures": 0,
                    "critical_issues": 0,
                    "needs_immediate_action": False,
                    "test_health_score": 100,
                    "message": "🎉 All tests passed! Excellent work!"
                },
                "test_failures": [],
                "actionable_recommendations": [
                    {
                        "priority": "P3 - Enhancement",
                        "action": "Consider expanding test coverage",
                        "details": "Add more edge cases and error scenarios"
                    },
                    {
                        "priority": "P3 - Enhancement",
                        "action": "Review test data",
                        "details": "Ensure test data covers all user flows"
                    }
                ]
            }
        
        # Build prompt for AI
        prompt = f"""Analyze these Playwright E2E test failures and provide insights:

Test Failures ({len(failures)} total):
"""
        for i, failure in enumerate(failures, 1):
            prompt += f"""
{i}. Test: {failure['title']}
   File: {failure['file']}
   Error: {failure['error']}
   Duration: {failure['duration']}ms
"""
        
        prompt += """

Please provide:
1. Root cause analysis for each failure
2. Common patterns across failures
3. Actionable recommendations to fix
4. Priority order (high/medium/low)

Format response as JSON with this structure:
{
  "failures_analysis": [
    {
      "test_title": "...",
      "root_cause": "...",
      "recommended_fix": "...",
      "priority": "high|medium|low"
    }
  ],
  "common_patterns": ["..."],
  "recommendations": ["..."]
}
"""
        
        # Call GitHub Models API
        headers = {
            "Authorization": f"Bearer {github_token}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "model": "gpt-4o",
            "messages": [
                {
                    "role": "system",
                    "content": "You are an expert QA engineer analyzing E2E test failures. Provide clear, actionable insights."
                },
                {
                    "role": "user",
                    "content": prompt
                }
            ],
            "temperature": 0.3,
            "max_tokens": 2000
        }
        
        response = requests.post(
            "https://models.inference.ai.azure.com/chat/completions",
            headers=headers,
            json=payload,
            timeout=30
        )
        
        if response.status_code == 200:
            ai_response = response.json()
            ai_content = ai_response['choices'][0]['message']['content']
            
            # Try to parse AI response as JSON
            try:
                ai_analysis = json.loads(ai_content)
            except json.JSONDecodeError:
                # If not JSON, create structured response from text
                ai_analysis = {
                    "failures_analysis": [],
                    "common_patterns": ["AI analysis available in text format"],
                    "recommendations": [ai_content[:500]]
                }
            
            # Enhance with detailed failure info
            detailed_failures = [analyze_failure_details(f) for f in failures]
            
            # Calculate severity
            severity_count = {
                "high": sum(1 for f in detailed_failures if f['severity'] == 'high'),
                "medium": sum(1 for f in detailed_failures if f['severity'] == 'medium'),
                "low": sum(1 for f in detailed_failures if f['severity'] == 'low')
            }
            
            return {
                "analysis_metadata": {
                    "timestamp": datetime.utcnow().isoformat() + "Z",
                    "status": "success",
                    "ai_provider": "github-copilot",
                    "model": "gpt-4o",
                    "token_usage": ai_response.get('usage', {}),
                    "version": "2.0"
                },
                "executive_summary": {
                    "total_failures": len(failures),
                    "critical_issues": severity_count['high'],
                    "needs_immediate_action": severity_count['high'] > 0,
                    "estimated_fix_time_minutes": 5 * severity_count['high'] + 2 * severity_count['medium'],
                    "test_health_score": max(0, 100 - (severity_count['high'] * 30 + severity_count['medium'] * 10)),
                    "ai_confidence": "high"
                },
                "failure_breakdown": {
                    "by_severity": severity_count,
                    "total_duration_ms": sum(f['duration_ms'] for f in detailed_failures)
                },
                "detailed_analysis": detailed_failures,
                "ai_insights": ai_analysis,
                "actionable_recommendations": ai_analysis.get('recommendations', [])
            }
        else:
            print(f"⚠️  GitHub Models API error: {response.status_code}")
            print(f"Response: {response.text}")
            return create_fallback_analysis(failures)
            
    except ImportError:
        print("⚠️  'requests' library not installed, using fallback analysis")
        return create_fallback_analysis(failures)
    except Exception as e:
        print(f"⚠️  AI analysis error: {e}")
        return create_fallback_analysis(failures)

def analyze_failure_details(failure):
    """Analyze individual failure and extract insights"""
    error_msg = failure.get('error', '').lower()
    
    # Determine failure type
    if 'timeout' in error_msg:
        failure_type = "timeout"
        severity = "high" if failure.get('duration', 0) > 30000 else "medium"
    elif 'selector' in error_msg or 'locator' in error_msg:
        failure_type = "selector"
        severity = "high"
    elif 'network' in error_msg or 'connection' in error_msg:
        failure_type = "network"
        severity = "medium"
    elif 'assertion' in error_msg or 'expect' in error_msg:
        failure_type = "assertion"
        severity = "medium"
    else:
        failure_type = "unknown"
        severity = "low"
    
    # Extract selector if present
    selector = None
    error_text = failure.get('error', '')
    if 'locator' in error_msg or 'waiting for' in error_msg:
        import re
        # Try multiple patterns
        patterns = [
            r"locator\(['\"]([^'\"]+)['\"]\)",  # locator('...')
            r"waiting for locator\('([^']+)'\)",  # waiting for locator('...')
            r'waiting for locator\("([^"]+)"\)',  # waiting for locator("...")
            r"locator\('([^']+)'\)",  # locator('...')
            r'locator\("([^"]+)"\)',  # locator("...")
        ]
        
        for pattern in patterns:
            match = re.search(pattern, error_text)
            if match:
                selector = match.group(1)
                break
    
    # Root cause analysis
    root_cause = ""
    fix_suggestion = ""
    code_example = ""
    
    if failure_type == "timeout":
        if selector and ('productsdd' in selector or 'loginssss' in selector):
            root_cause = "Incorrect selector path - typo in URL"
            fix_suggestion = f"Fix the selector path by removing typo"
            if 'productsdd' in selector:
                code_example = f"// ❌ Wrong\nawait page.click('a[href=\"/productsdd\"]');\n\n// ✅ Correct\nawait page.click('a[href=\"/products\"]');"
            elif 'loginssss' in selector:
                code_example = f"// ❌ Wrong\nawait page.click('a[href=\"/loginssss\"]');\n\n// ✅ Correct\nawait page.click('a[href=\"/login\"]');"
        else:
            root_cause = "Element not found within timeout period"
            fix_suggestion = "Increase timeout or add explicit wait for element"
            code_example = "// Add explicit wait\nawait page.waitForSelector('selector', { timeout: 10000 });\nawait page.click('selector');"
    
    elif failure_type == "selector":
        root_cause = "Element selector is invalid or element doesn't exist"
        fix_suggestion = "Verify element exists in DOM and selector is correct"
        code_example = "// Use more robust selector\nawait page.locator('[data-testid=\"element\"]').click();\n\n// Or use getByRole\nawait page.getByRole('button', { name: 'Click me' }).click();"
    
    elif failure_type == "assertion":
        root_cause = "Expected value doesn't match actual value"
        fix_suggestion = "Review test expectations and actual application behavior"
        code_example = "// Add better assertions\nawait expect(page).toHaveURL(/.*expected-path/);\nawait expect(element).toBeVisible();"
    
    return {
        "test_title": failure.get('title', 'Unknown'),
        "file": failure.get('file', 'Unknown'),
        "failure_type": failure_type,
        "severity": severity,
        "root_cause": root_cause or "Needs investigation",
        "fix_suggestion": fix_suggestion or "Review test logic and application state",
        "affected_selector": selector,
        "code_example": code_example,
        "duration_ms": failure.get('duration', 0),
        "error_snippet": failure.get('error', '')[:200] + "..." if len(failure.get('error', '')) > 200 else failure.get('error', '')
    }

def create_fallback_analysis(failures):
    """Create professional analysis without AI when API fails"""
    
    # Detailed failure analysis
    detailed_failures = [analyze_failure_details(f) for f in failures]
    
    # Pattern detection
    patterns = {
        "timeout_failures": sum(1 for f in detailed_failures if f['failure_type'] == 'timeout'),
        "selector_issues": sum(1 for f in detailed_failures if f['failure_type'] == 'selector'),
        "network_issues": sum(1 for f in detailed_failures if f['failure_type'] == 'network'),
        "assertion_failures": sum(1 for f in detailed_failures if f['failure_type'] == 'assertion')
    }
    
    # Severity breakdown
    severity_count = {
        "high": sum(1 for f in detailed_failures if f['severity'] == 'high'),
        "medium": sum(1 for f in detailed_failures if f['severity'] == 'medium'),
        "low": sum(1 for f in detailed_failures if f['severity'] == 'low')
    }
    
    # Common issues detection
    common_issues = []
    if patterns['timeout_failures'] > 1:
        common_issues.append({
            "issue": "Multiple timeout failures",
            "count": patterns['timeout_failures'],
            "impact": "high",
            "recommendation": "Review selectors for typos and increase base timeout if needed"
        })
    
    if patterns['selector_issues'] > 0:
        common_issues.append({
            "issue": "Selector-related failures",
            "count": patterns['selector_issues'],
            "impact": "high",
            "recommendation": "Use more robust selectors (data-testid, getByRole) instead of CSS paths"
        })
    
    # Specific typos detected
    typo_selectors = [f for f in detailed_failures if f.get('affected_selector') and ('dd' in f['affected_selector'] or 'ssss' in f['affected_selector'])]
    if typo_selectors:
        common_issues.append({
            "issue": "Typos in selectors detected",
            "count": len(typo_selectors),
            "impact": "critical",
            "recommendation": "Fix selector typos immediately - this is causing test failures",
            "examples": [f['affected_selector'] for f in typo_selectors if f.get('affected_selector')]
        })
    
    # Actionable recommendations
    recommendations = []
    
    if severity_count['high'] > 0:
        recommendations.append({
            "priority": "P0 - Critical",
            "action": f"Fix {severity_count['high']} high-severity failures immediately",
            "impact": "Blocking test suite execution"
        })
    
    if typo_selectors:
        recommendations.append({
            "priority": "P0 - Critical",
            "action": "Fix selector typos in smoke tests",
            "files_affected": list(set(f['file'] for f in typo_selectors)),
            "estimated_fix_time": "5 minutes"
        })
    
    if patterns['timeout_failures'] > 1:
        recommendations.append({
            "priority": "P1 - High",
            "action": "Review timeout configuration",
            "details": "Consider increasing default timeout or adding explicit waits",
            "config_suggestion": "// playwright.config.ts\nuse: {\n  timeout: 10000, // Increase from 5000\n}"
        })
    
    recommendations.append({
        "priority": "P2 - Medium",
        "action": "Improve selector strategy",
        "details": "Use data-testid or getByRole for more stable selectors",
        "example": "await page.getByRole('link', { name: 'Products' }).click();"
    })
    
    # Test health metrics
    total_duration = sum(f['duration_ms'] for f in detailed_failures)
    avg_duration = total_duration / len(detailed_failures) if detailed_failures else 0
    
    return {
        "analysis_metadata": {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "status": "success",
            "analysis_engine": "pattern-based-advanced",
            "message": "Professional analysis without AI (fallback mode)",
            "version": "2.0"
        },
        "executive_summary": {
            "total_failures": len(failures),
            "critical_issues": severity_count['high'],
            "needs_immediate_action": severity_count['high'] > 0,
            "estimated_fix_time_minutes": 5 * severity_count['high'] + 2 * severity_count['medium'],
            "test_health_score": max(0, 100 - (severity_count['high'] * 30 + severity_count['medium'] * 10))
        },
        "failure_breakdown": {
            "by_type": patterns,
            "by_severity": severity_count,
            "average_failure_duration_ms": int(avg_duration)
        },
        "detailed_analysis": detailed_failures,
        "common_issues": common_issues,
        "actionable_recommendations": recommendations,
        "quick_wins": [
            {
                "action": "Fix selector typos",
                "files": ["tests/smoke/smoke-home.spec.ts"],
                "effort": "5 minutes",
                "impact": "Resolves 100% of current failures"
            }
        ] if typo_selectors else []
    }

def main():
    """Main execution"""
    import argparse
    
    parser = argparse.ArgumentParser(description='AI Test Analysis')
    parser.add_argument('input_file', nargs='?', help='Test results JSON file')
    parser.add_argument('output_file', nargs='?', default='analysis-output.json', help='Output JSON file')
    parser.add_argument('--fallback', action='store_true', help='Use fallback analysis mode')
    parser.add_argument('--test-results', help='Path to test results directory')
    
    args = parser.parse_args()
    
    # Handle different argument patterns
    if args.fallback:
        # Fallback mode - create sample analysis
        print("⚠️  Running in fallback mode (no test results)", file=sys.stderr)
        test_results = {"suites": []}
        output_file = args.output_file or 'analysis-output.json'
    elif args.test_results:
        # Directory path provided
        import glob
        json_files = glob.glob(f"{args.test_results}/*.json") or glob.glob(f"{args.test_results}/results.json")
        if json_files:
            input_file = json_files[0]
            print(f"📊 Loading test results from: {input_file}", file=sys.stderr)
            test_results = load_test_results(input_file)
        else:
            print("⚠️  No test results found in directory, using fallback", file=sys.stderr)
            test_results = {"suites": []}
        output_file = args.output_file or 'analysis-output.json'
    elif args.input_file:
        # Traditional mode - file paths
        input_file = args.input_file
        output_file = args.output_file or 'analysis-output.json'
        print(f"📊 Loading test results from: {input_file}", file=sys.stderr)
        test_results = load_test_results(input_file)
    else:
        print("❌ Error: No input provided", file=sys.stderr)
        print("Usage: python analyze-github.py <test-results.json> <output.json>", file=sys.stderr)
        print("   or: python analyze-github.py --fallback", file=sys.stderr)
        print("   or: python analyze-github.py --test-results <directory>", file=sys.stderr)
        sys.exit(1)
    
    # Get GitHub token from environment
    github_token = os.getenv('GITHUB_TOKEN')
    
    if github_token:
        print("🤖 Using GitHub Copilot/Models for AI analysis...", file=sys.stderr)
        analysis = analyze_with_github_models(test_results, github_token)
    else:
        print("⚠️  GITHUB_TOKEN not found, using fallback analysis", file=sys.stderr)
        
        # Extract failures for fallback
        failures = []
        for suite in test_results.get('suites', []):
            for spec in suite.get('specs', []):
                for test in spec.get('tests', []):
                    for result in test.get('results', []):
                        status = result.get('status', '')
                        if status in ['failed', 'timedOut']:
                            # Extract error message properly
                            error_obj = result.get('error', {})
                            error_msg = 'No error message'
                            
                            if isinstance(error_obj, dict):
                                error_msg = error_obj.get('message', error_obj.get('value', 'No error message'))
                            elif isinstance(error_obj, str):
                                error_msg = error_obj
                            
                            failures.append({
                                'title': test.get('title', 'Unknown'),
                                'file': spec.get('file', 'Unknown'),
                                'error': error_msg,
                                'duration': result.get('duration', 0),
                                'status': status
                            })
        
        print(f"🔍 Found {len(failures)} failures for fallback analysis", file=sys.stderr)
        analysis = create_fallback_analysis(failures)
    
    # Write output
    print(f"💾 Writing analysis to: {output_file}", file=sys.stderr)
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(analysis, f, indent=2, ensure_ascii=False)
    
    # Also print to stdout for workflow capture
    print(json.dumps(analysis, indent=2, ensure_ascii=False))
    
    # Print summary to stderr so it shows in logs
    print("\n" + "="*70, file=sys.stderr)
    print("📊 AI TEST ANALYSIS REPORT", file=sys.stderr)
    print("="*70, file=sys.stderr)
    
    metadata = analysis['analysis_metadata']
    print(f"Timestamp:     {metadata['timestamp']}", file=sys.stderr)
    print(f"Status:        {metadata['status']}", file=sys.stderr)
    print(f"Engine:        {metadata.get('ai_provider', metadata.get('analysis_engine', 'N/A'))}", file=sys.stderr)
    
    if 'executive_summary' in analysis:
        summary = analysis['executive_summary']
        print("\n" + "-"*70, file=sys.stderr)
        print("EXECUTIVE SUMMARY", file=sys.stderr)
        print("-"*70, file=sys.stderr)
        print(f"Total Failures:           {summary.get('total_failures', 0)}", file=sys.stderr)
        print(f"Critical Issues:          {summary.get('critical_issues', 0)}", file=sys.stderr)
        print(f"Test Health Score:        {summary.get('test_health_score', 0)}/100", file=sys.stderr)
        print(f"Estimated Fix Time:       {summary.get('estimated_fix_time_minutes', 0)} minutes", file=sys.stderr)
        
        if summary.get('needs_immediate_action'):
            print(f"\n⚠️  ACTION REQUIRED: {summary.get('critical_issues', 0)} critical issues need immediate attention!", file=sys.stderr)
        else:
            print(f"\n✅ {summary.get('message', 'Analysis complete')}", file=sys.stderr)
    
    if 'detailed_analysis' in analysis and analysis['detailed_analysis']:
        print("\n" + "-"*70, file=sys.stderr)
        print("TOP ISSUES", file=sys.stderr)
        print("-"*70, file=sys.stderr)
        for i, failure in enumerate(analysis['detailed_analysis'][:3], 1):
            print(f"\n{i}. [{failure.get('severity', 'N/A').upper()}] {failure.get('test_title', 'Unknown')}", file=sys.stderr)
            print(f"   Root Cause: {failure.get('root_cause', 'N/A')}", file=sys.stderr)
            print(f"   Fix: {failure.get('fix_suggestion', 'N/A')}", file=sys.stderr)
    
    if 'actionable_recommendations' in analysis and analysis['actionable_recommendations']:
        print("\n" + "-"*70, file=sys.stderr)
        print("RECOMMENDED ACTIONS", file=sys.stderr)
        print("-"*70, file=sys.stderr)
        for i, rec in enumerate(analysis['actionable_recommendations'][:3], 1):
            if isinstance(rec, dict):
                print(f"{i}. [{rec.get('priority', 'N/A')}] {rec.get('action', 'N/A')}", file=sys.stderr)
            else:
                print(f"{i}. {rec}", file=sys.stderr)
    
    print("\n" + "="*70, file=sys.stderr)
    print(f"✅ Full report saved to: {output_file}", file=sys.stderr)
    print("="*70, file=sys.stderr)

if __name__ == '__main__':
    main()
