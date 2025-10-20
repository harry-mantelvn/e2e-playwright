#!/usr/bin/env python3
"""
AI Test Analysis using GitHub Models (Copilot)
Zero-cost, token-based authentication via GITHUB_TOKEN
"""

import json
import sys
import os
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any
import requests

class GitHubModelsAnalyzer:
    """Analyzer using GitHub Models API (GitHub Copilot backend)"""
    
    def __init__(self, token: str, model: str = "gpt-4o"):
        """
        Initialize with GitHub token
        
        Args:
            token: GitHub token (from GITHUB_TOKEN)
            model: Model to use (gpt-4o, gpt-4o-mini, o1-preview, o1-mini)
        """
        self.token = token
        self.model = model
        self.api_url = "https://models.inference.ai.azure.com/chat/completions"
        
    def analyze_test_report(self, report_data: Dict) -> Dict:
        """Analyze test report using GitHub Models"""
        
        prompt = self._build_analysis_prompt(report_data)
        
        try:
            response = requests.post(
                self.api_url,
                headers={
                    "Authorization": f"Bearer {self.token}",
                    "Content-Type": "application/json"
                },
                json={
                    "model": self.model,
                    "messages": [
                        {
                            "role": "system",
                            "content": "You are an expert QA automation engineer analyzing test results. Provide actionable insights, root cause analysis, and recommendations."
                        },
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ],
                    "temperature": 0.3,
                    "max_tokens": 2000
                },
                timeout=60
            )
            
            if response.status_code != 200:
                print(f"❌ GitHub Models API error: {response.status_code}")
                print(f"Response: {response.text}")
                return self._fallback_analysis(report_data)
            
            result = response.json()
            ai_response = result['choices'][0]['message']['content']
            
            # Parse AI response and structure it
            analysis = self._parse_ai_response(ai_response, report_data)
            return analysis
            
        except Exception as e:
            print(f"❌ Error calling GitHub Models API: {str(e)}")
            return self._fallback_analysis(report_data)
    
    def _build_analysis_prompt(self, report_data: Dict) -> str:
        """Build analysis prompt for GitHub Models"""
        
        total_tests = report_data.get('total_test_cases', 0)
        passed = report_data.get('passed_tests', 0)
        failed = report_data.get('failed_tests', 0)
        pass_rate = report_data.get('pass_rate', 0)
        
        failed_tests_info = ""
        if report_data.get('failed_test_details'):
            failed_tests_info = "\n\nFailed Tests Details:\n"
            for test in report_data['failed_test_details'][:5]:  # Top 5 failures
                failed_tests_info += f"- {test.get('name', 'Unknown')}\n"
                failed_tests_info += f"  Error: {test.get('error', 'No error message')}\n"
        
        prompt = f"""Analyze this E2E test execution report:

Test Metrics:
- Total Test Cases: {total_tests}
- Passed: {passed}
- Failed: {failed}
- Pass Rate: {pass_rate}%
- Environment: {report_data.get('environment', 'test')}
- Test Scope: {report_data.get('test_scope', 'all')}
{failed_tests_info}

Please provide:
1. Overall quality assessment (Excellent/Good/Needs Attention/Critical)
2. Key insights about test failures (if any)
3. Root cause analysis for failures
4. Actionable recommendations
5. Risk assessment and deployment readiness

Format your response as JSON with these fields:
- quality_status: string
- overall_insights: string
- failure_analysis: array of objects with pattern, root_cause, impact
- recommendations: array of strings
- risk_assessment: object with level, deployment_ready, concerns
- ai_summary: string"""

        return prompt
    
    def _parse_ai_response(self, ai_response: str, report_data: Dict) -> Dict:
        """Parse AI response and structure analysis"""
        
        try:
            # Try to extract JSON from response
            if "```json" in ai_response:
                json_start = ai_response.find("```json") + 7
                json_end = ai_response.find("```", json_start)
                json_str = ai_response[json_start:json_end].strip()
                ai_analysis = json.loads(json_str)
            elif "{" in ai_response and "}" in ai_response:
                json_start = ai_response.find("{")
                json_end = ai_response.rfind("}") + 1
                json_str = ai_response[json_start:json_end]
                ai_analysis = json.loads(json_str)
            else:
                # Parse as structured text
                ai_analysis = {
                    "quality_status": self._extract_quality_status(report_data),
                    "overall_insights": ai_response,
                    "failure_analysis": [],
                    "recommendations": self._extract_recommendations(ai_response),
                    "risk_assessment": self._assess_risk(report_data),
                    "ai_summary": ai_response[:500]
                }
        except:
            ai_analysis = {
                "quality_status": self._extract_quality_status(report_data),
                "overall_insights": ai_response,
                "failure_analysis": [],
                "recommendations": [],
                "risk_assessment": self._assess_risk(report_data),
                "ai_summary": ai_response[:500]
            }
        
        # Enhance with statistical analysis
        return self._enhance_with_statistics(ai_analysis, report_data)
    
    def _extract_quality_status(self, report_data: Dict) -> str:
        """Extract quality status from metrics"""
        pass_rate = report_data.get('pass_rate', 0)
        if pass_rate >= 95:
            return "Excellent"
        elif pass_rate >= 85:
            return "Good"
        elif pass_rate >= 70:
            return "Needs Attention"
        else:
            return "Critical"
    
    def _extract_recommendations(self, text: str) -> List[str]:
        """Extract recommendations from text"""
        recommendations = []
        lines = text.split('\n')
        in_recommendations = False
        
        for line in lines:
            if 'recommendation' in line.lower():
                in_recommendations = True
                continue
            if in_recommendations and line.strip().startswith(('-', '•', '*', '1.', '2.', '3.')):
                rec = line.strip().lstrip('-•*123456789. ')
                if rec:
                    recommendations.append(rec)
        
        return recommendations[:5]  # Top 5
    
    def _assess_risk(self, report_data: Dict) -> Dict:
        """Assess deployment risk"""
        pass_rate = report_data.get('pass_rate', 0)
        failed = report_data.get('failed_tests', 0)
        
        if pass_rate >= 95:
            return {
                "level": "Low",
                "deployment_ready": True,
                "concerns": []
            }
        elif pass_rate >= 85:
            return {
                "level": "Medium",
                "deployment_ready": True,
                "concerns": ["Minor test failures detected. Review before production deployment."]
            }
        elif pass_rate >= 70:
            return {
                "level": "High",
                "deployment_ready": False,
                "concerns": [
                    f"{failed} test failures detected",
                    "Requires immediate investigation",
                    "Deployment should be delayed until issues resolved"
                ]
            }
        else:
            return {
                "level": "Critical",
                "deployment_ready": False,
                "concerns": [
                    f"Critical: {failed} test failures",
                    "BLOCK DEPLOYMENT immediately",
                    "Emergency team review required"
                ]
            }
    
    def _enhance_with_statistics(self, ai_analysis: Dict, report_data: Dict) -> Dict:
        """Enhance AI analysis with statistical data"""
        
        analysis = {
            "timestamp": datetime.now().isoformat(),
            "analyzer": "GitHub Models (Copilot)",
            "model": self.model,
            "report_metadata": {
                "environment": report_data.get('environment', 'test'),
                "test_scope": report_data.get('test_scope', 'all'),
                "run_number": report_data.get('run_number', 'N/A'),
                "execution_time": report_data.get('execution_time', 'N/A')
            },
            "test_metrics": {
                "total_test_cases": report_data.get('total_test_cases', 0),
                "passed_tests": report_data.get('passed_tests', 0),
                "failed_tests": report_data.get('failed_tests', 0),
                "skipped_tests": report_data.get('skipped_tests', 0),
                "pass_rate": report_data.get('pass_rate', 0),
                "test_coverage": report_data.get('test_coverage_percentage', 85)
            },
            "ai_analysis": ai_analysis,
            "statistical_analysis": self._perform_statistical_analysis(report_data),
            "trends": self._analyze_trends(report_data),
            "action_items": self._generate_action_items(ai_analysis, report_data)
        }
        
        return analysis
    
    def _perform_statistical_analysis(self, report_data: Dict) -> Dict:
        """Perform statistical analysis on test data"""
        
        pass_rate = report_data.get('pass_rate', 0)
        total = report_data.get('total_test_cases', 0)
        failed = report_data.get('failed_tests', 0)
        
        return {
            "failure_rate": round(100 - pass_rate, 2),
            "reliability_score": round(pass_rate / 100, 3),
            "failure_impact": "Critical" if failed > total * 0.15 else "Medium" if failed > total * 0.05 else "Low",
            "confidence_level": "High" if pass_rate >= 95 else "Medium" if pass_rate >= 85 else "Low"
        }
    
    def _analyze_trends(self, report_data: Dict) -> Dict:
        """Analyze trends (placeholder for historical data)"""
        
        return {
            "trend_direction": "stable",
            "note": "Historical trend analysis requires multiple test runs. This is the current snapshot.",
            "pass_rate_current": report_data.get('pass_rate', 0)
        }
    
    def _generate_action_items(self, ai_analysis: Dict, report_data: Dict) -> List[Dict]:
        """Generate prioritized action items"""
        
        action_items = []
        pass_rate = report_data.get('pass_rate', 0)
        failed = report_data.get('failed_tests', 0)
        
        if failed > 0:
            action_items.append({
                "priority": "High",
                "action": f"Investigate and fix {failed} failed test case(s)",
                "owner": "QA Team",
                "deadline": "Next sprint"
            })
        
        if pass_rate < 95:
            action_items.append({
                "priority": "Medium",
                "action": "Improve test stability to achieve 95%+ pass rate",
                "owner": "Dev Team",
                "deadline": "Within 2 weeks"
            })
        
        # Add AI recommendations as action items
        for rec in ai_analysis.get('recommendations', [])[:3]:
            action_items.append({
                "priority": "Medium",
                "action": rec,
                "owner": "Team",
                "deadline": "TBD"
            })
        
        return action_items
    
    def _fallback_analysis(self, report_data: Dict) -> Dict:
        """Fallback analysis when AI fails"""
        
        pass_rate = report_data.get('pass_rate', 0)
        quality_status = self._extract_quality_status(report_data)
        
        return {
            "timestamp": datetime.now().isoformat(),
            "analyzer": "Fallback Statistical Analyzer",
            "model": "rule-based",
            "report_metadata": {
                "environment": report_data.get('environment', 'test'),
                "test_scope": report_data.get('test_scope', 'all'),
                "run_number": report_data.get('run_number', 'N/A')
            },
            "test_metrics": {
                "total_test_cases": report_data.get('total_test_cases', 0),
                "passed_tests": report_data.get('passed_tests', 0),
                "failed_tests": report_data.get('failed_tests', 0),
                "pass_rate": pass_rate
            },
            "ai_analysis": {
                "quality_status": quality_status,
                "overall_insights": f"Test execution completed with {pass_rate}% pass rate. {quality_status} quality level achieved.",
                "failure_analysis": [],
                "recommendations": [
                    "Review failed test cases for patterns",
                    "Check test environment stability",
                    "Update test data if needed"
                ],
                "risk_assessment": self._assess_risk(report_data),
                "ai_summary": "Fallback analysis - GitHub Models API unavailable"
            },
            "statistical_analysis": self._perform_statistical_analysis(report_data),
            "action_items": self._generate_action_items({"recommendations": []}, report_data)
        }


def load_test_report(report_path: str) -> Dict:
    """Load test report from metrics.json"""
    try:
        with open(report_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"❌ Error loading report: {str(e)}")
        return {}


def save_analysis(analysis: Dict, output_path: str):
    """Save AI analysis to JSON file"""
    try:
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(analysis, f, indent=2, ensure_ascii=False)
        print(f"✅ Analysis saved to {output_path}")
    except Exception as e:
        print(f"❌ Error saving analysis: {str(e)}")


def main():
    """Main execution function"""
    
    print("🤖 Starting AI Test Analysis with GitHub Models...")
    
    # Get GitHub token
    github_token = os.getenv('GITHUB_TOKEN')
    if not github_token:
        print("❌ Error: GITHUB_TOKEN environment variable not set")
        sys.exit(1)
    
    # Get model (optional)
    model = os.getenv('GITHUB_MODEL', 'gpt-4o')
    print(f"📊 Using model: {model}")
    
    # Load test report
    report_path = os.getenv('REPORT_PATH', 'automationexercise-e2e-pom/test-summary/metrics.json')
    print(f"📂 Loading report from: {report_path}")
    
    report_data = load_test_report(report_path)
    if not report_data:
        print("❌ No test data to analyze")
        sys.exit(1)
    
    print(f"📊 Test Metrics:")
    print(f"   - Total: {report_data.get('total_test_cases', 0)}")
    print(f"   - Passed: {report_data.get('passed_tests', 0)}")
    print(f"   - Failed: {report_data.get('failed_tests', 0)}")
    print(f"   - Pass Rate: {report_data.get('pass_rate', 0)}%")
    
    # Initialize analyzer
    analyzer = GitHubModelsAnalyzer(token=github_token, model=model)
    
    # Perform analysis
    print("🔍 Analyzing test results with GitHub Models AI...")
    analysis = analyzer.analyze_test_report(report_data)
    
    # Save results
    output_path = os.getenv('OUTPUT_PATH', 'automationexercise-e2e-pom/test-summary/ai-analysis.json')
    save_analysis(analysis, output_path)
    
    # Print summary
    print("\n📋 AI Analysis Summary:")
    print(f"   - Quality Status: {analysis['ai_analysis']['quality_status']}")
    print(f"   - Risk Level: {analysis['ai_analysis']['risk_assessment']['level']}")
    print(f"   - Deployment Ready: {analysis['ai_analysis']['risk_assessment']['deployment_ready']}")
    print(f"   - Action Items: {len(analysis['action_items'])}")
    
    print("\n✅ AI Analysis Complete!")


if __name__ == "__main__":
    main()
