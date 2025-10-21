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
            return json.load(f)
    except FileNotFoundError:
        print(f"❌ Error: Test results file not found: {json_path}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"❌ Error: Invalid JSON in {json_path}: {e}")
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
                        if result.get('status') in ['failed', 'timedOut']:
                            failures.append({
                                'title': test.get('title', 'Unknown'),
                                'file': spec.get('file', 'Unknown'),
                                'error': result.get('error', {}).get('message', 'No error message'),
                                'duration': result.get('duration', 0)
                            })
        
        if not failures:
            return {
                "analysis_metadata": {
                    "timestamp": datetime.utcnow().isoformat() + "Z",
                    "status": "success",
                    "ai_provider": "github-copilot",
                    "model": "gpt-4o"
                },
                "summary": {
                    "ai_enabled": True,
                    "total_failures_analyzed": 0,
                    "message": "All tests passed! No failures to analyze."
                },
                "test_failures": [],
                "recommendations": [
                    "✅ All tests passing - great job!",
                    "💡 Consider adding more test coverage",
                    "🔄 Review test data for edge cases"
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
                # If not JSON, create structured response
                ai_analysis = {
                    "failures_analysis": [],
                    "common_patterns": ["Analysis available in text format"],
                    "recommendations": [ai_content[:500]]  # First 500 chars
                }
            
            return {
                "analysis_metadata": {
                    "timestamp": datetime.utcnow().isoformat() + "Z",
                    "status": "success",
                    "ai_provider": "github-copilot",
                    "model": "gpt-4o",
                    "token_usage": ai_response.get('usage', {})
                },
                "summary": {
                    "ai_enabled": True,
                    "total_failures_analyzed": len(failures),
                    "analysis_quality": "high"
                },
                "test_failures": failures,
                "ai_insights": ai_analysis
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

def create_fallback_analysis(failures):
    """Create analysis without AI when API fails"""
    
    # Simple pattern detection
    patterns = []
    if any('timeout' in f.get('error', '').lower() for f in failures):
        patterns.append("⏱️  Multiple timeout failures detected")
    if any('selector' in f.get('error', '').lower() for f in failures):
        patterns.append("🎯 Selector issues found")
    if any('network' in f.get('error', '').lower() for f in failures):
        patterns.append("🌐 Network-related failures")
    
    recommendations = [
        "🔍 Review test selectors for stability",
        "⏱️  Increase timeout values if needed",
        "🔄 Check for race conditions",
        "📊 Review test data and fixtures"
    ]
    
    return {
        "analysis_metadata": {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "status": "fallback",
            "message": "Using statistical analysis (AI unavailable)"
        },
        "summary": {
            "ai_enabled": False,
            "total_failures_analyzed": len(failures),
            "analysis_type": "pattern-based"
        },
        "test_failures": failures,
        "patterns_detected": patterns,
        "recommendations": recommendations
    }

def main():
    """Main execution"""
    if len(sys.argv) < 3:
        print("Usage: python analyze-github.py <test-results.json> <output.json>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    print(f"📊 Loading test results from: {input_file}")
    test_results = load_test_results(input_file)
    
    # Get GitHub token from environment
    github_token = os.getenv('GITHUB_TOKEN')
    
    if github_token:
        print("🤖 Using GitHub Copilot/Models for AI analysis...")
        analysis = analyze_with_github_models(test_results, github_token)
    else:
        print("⚠️  GITHUB_TOKEN not found, using fallback analysis")
        
        # Extract failures for fallback
        failures = []
        for suite in test_results.get('suites', []):
            for spec in suite.get('specs', []):
                for test in spec.get('tests', []):
                    for result in test.get('results', []):
                        if result.get('status') in ['failed', 'timedOut']:
                            failures.append({
                                'title': test.get('title', 'Unknown'),
                                'file': spec.get('file', 'Unknown'),
                                'error': result.get('error', {}).get('message', 'No error message')
                            })
        
        analysis = create_fallback_analysis(failures)
    
    # Write output
    print(f"💾 Writing analysis to: {output_file}")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(analysis, f, indent=2, ensure_ascii=False)
    
    # Print summary
    print("\n" + "="*60)
    print("📊 AI ANALYSIS SUMMARY")
    print("="*60)
    print(f"Status: {analysis['analysis_metadata']['status']}")
    print(f"AI Enabled: {analysis['summary'].get('ai_enabled', False)}")
    print(f"Failures Analyzed: {analysis['summary'].get('total_failures_analyzed', 0)}")
    
    if 'ai_insights' in analysis:
        print(f"\n✅ AI insights generated successfully!")
    elif 'patterns_detected' in analysis:
        print(f"\n⚠️  Using pattern-based analysis")
        print(f"Patterns: {', '.join(analysis['patterns_detected'])}")
    
    print("="*60)
    print(f"✅ Analysis complete! Results saved to: {output_file}")

if __name__ == '__main__':
    main()
