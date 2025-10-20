"""
AI-Powered Test Analysis System
NVIDIA-Grade Quality Engineering

Analyzes test results using:
1. OpenAI GPT-4 for semantic analysis
2. Scikit-learn for statistical analysis
3. Pattern recognition for root cause detection
"""

import json
import os
import sys
from typing import Dict, List, Optional
from datetime import datetime
import re

try:
    from openai import OpenAI
    import numpy as np
    from sklearn.ensemble import IsolationForest
    from scipy.stats import entropy
except ImportError as e:
    print(f"❌ Missing dependency: {e}")
    print("Install with: pip install openai scikit-learn scipy numpy")
    sys.exit(1)


class TestAnalysisAI:
    """Main AI analysis orchestrator"""
    
    def __init__(self, openai_api_key: Optional[str] = None):
        """Initialize AI analyzer"""
        self.api_key = openai_api_key or os.getenv('OPENAI_API_KEY')
        if self.api_key:
            self.client = OpenAI(api_key=self.api_key)
            self.ai_enabled = True
        else:
            print("⚠️  OpenAI API key not found. Running with statistical analysis only.")
            self.ai_enabled = False
        
        self.analysis_results = {
            "analysis_metadata": {
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "model": "gpt-4" if self.ai_enabled else "statistical-only",
                "version": "1.0.0"
            },
            "failure_categorization": [],
            "flaky_tests": [],
            "performance_anomalies": [],
            "root_cause_analysis": [],
            "recommendations": [],
            "summary": {}
        }
    
    def analyze(self, test_results: Dict, historical_data: Optional[Dict] = None) -> Dict:
        """
        Main analysis entry point
        
        Args:
            test_results: Current test run results
            historical_data: Optional historical test data for trend analysis
        
        Returns:
            Complete AI analysis results
        """
        print("🤖 Starting AI-powered test analysis...")
        
        # Extract data
        failed_tests = self._extract_failed_tests(test_results)
        performance_data = self._extract_performance_data(test_results)
        
        # Run analyses
        if failed_tests:
            print(f"📊 Analyzing {len(failed_tests)} failed tests...")
            
            # AI-powered failure categorization
            if self.ai_enabled:
                self.analysis_results['failure_categorization'] = \
                    self._categorize_failures(failed_tests)
                
                self.analysis_results['root_cause_analysis'] = \
                    self._analyze_root_causes(failed_tests)
            
        # Statistical analyses (don't require AI)
        if historical_data:
            print("📈 Analyzing historical trends...")
            self.analysis_results['flaky_tests'] = \
                self._detect_flaky_tests(historical_data)
        
        if performance_data:
            print("⚡ Analyzing performance anomalies...")
            self.analysis_results['performance_anomalies'] = \
                self._detect_performance_anomalies(performance_data)
        
        # Generate recommendations
        self.analysis_results['recommendations'] = \
            self._generate_recommendations(test_results)
        
        # Generate summary
        self.analysis_results['summary'] = \
            self._generate_summary(test_results)
        
        print("✅ Analysis complete!")
        return self.analysis_results
    
    def _extract_failed_tests(self, test_results: Dict) -> List[Dict]:
        """Extract failed test information from results"""
        failed = []
        
        # Try different result formats
        if 'failed_tests' in test_results:
            return test_results['failed_tests']
        
        # If we only have metrics, create minimal failed test entries
        failed_count = test_results.get('failed_tests', 0)
        if isinstance(failed_count, int) and failed_count > 0:
            for i in range(failed_count):
                failed.append({
                    'name': f'failed_test_{i+1}',
                    'error': 'Error details not available',
                    'file': 'unknown'
                })
        
        return failed
    
    def _extract_performance_data(self, test_results: Dict) -> List[Dict]:
        """Extract performance metrics from results"""
        if 'performance_metrics' in test_results:
            return test_results['performance_metrics'].get('test_durations', [])
        return []
    
    def _categorize_failures(self, failed_tests: List[Dict]) -> List[Dict]:
        """Use GPT-4 to categorize test failures"""
        categorizations = []
        
        for failure in failed_tests[:10]:  # Limit to avoid excessive API costs
            try:
                prompt = self._build_categorization_prompt(failure)
                
                response = self.client.chat.completions.create(
                    model="gpt-4",
                    messages=[
                        {
                            "role": "system",
                            "content": "You are an expert QA automation engineer specializing in test failure analysis. Provide concise, actionable insights."
                        },
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ],
                    temperature=0.3,  # Lower temperature for more consistent results
                    max_tokens=300
                )
                
                # Parse response
                content = response.choices[0].message.content
                categorization = self._parse_categorization_response(content, failure)
                categorizations.append(categorization)
                
            except Exception as e:
                print(f"⚠️  Error categorizing {failure.get('name')}: {e}")
                # Fallback categorization
                categorizations.append({
                    'test_name': failure.get('name', 'unknown'),
                    'category': 'UNKNOWN',
                    'confidence': 0,
                    'reasoning': f'Error during analysis: {str(e)}',
                    'suggested_action': 'Manual investigation required'
                })
        
        return categorizations
    
    def _build_categorization_prompt(self, failure: Dict) -> str:
        """Build GPT-4 prompt for failure categorization"""
        return f"""Analyze this test failure and categorize it:

Test Name: {failure.get('name', 'Unknown')}
File: {failure.get('file', 'Unknown')}
Error: {failure.get('error', 'No error message')}

Categories:
- FLAKY: Test passes/fails inconsistently (intermittent)
- INFRASTRUCTURE: Network, timeout, resource, environment issues
- CODE_BUG: Actual application bug/regression
- TEST_BUG: Test code issue (wrong selector, assertion, etc.)
- ENVIRONMENT: Configuration or environment-specific issue

Respond with:
Category: [ONE OF THE ABOVE]
Confidence: [0-100]%
Reasoning: [Brief 1-2 sentence explanation]
Action: [What should be done next]

Be concise and specific."""
    
    def _parse_categorization_response(self, content: str, failure: Dict) -> Dict:
        """Parse GPT-4 response into structured format"""
        # Extract category
        category_match = re.search(r'Category:\s*(\w+)', content, re.IGNORECASE)
        category = category_match.group(1).upper() if category_match else 'UNKNOWN'
        
        # Extract confidence
        confidence_match = re.search(r'Confidence:\s*(\d+)', content, re.IGNORECASE)
        confidence = int(confidence_match.group(1)) if confidence_match else 50
        
        # Extract reasoning
        reasoning_match = re.search(r'Reasoning:\s*(.+?)(?=Action:|$)', content, re.IGNORECASE | re.DOTALL)
        reasoning = reasoning_match.group(1).strip() if reasoning_match else content
        
        # Extract action
        action_match = re.search(r'Action:\s*(.+?)$', content, re.IGNORECASE | re.DOTALL)
        action = action_match.group(1).strip() if action_match else 'Investigate manually'
        
        return {
            'test_name': failure.get('name', 'unknown'),
            'category': category,
            'confidence': confidence,
            'reasoning': reasoning[:200],  # Limit length
            'suggested_action': action[:150]
        }
    
    def _analyze_root_causes(self, failed_tests: List[Dict]) -> List[Dict]:
        """Group failures and identify common root causes"""
        # Group by error pattern
        error_groups = {}
        
        for failure in failed_tests:
            error_type = self._extract_error_type(failure.get('error', ''))
            if error_type not in error_groups:
                error_groups[error_type] = []
            error_groups[error_type].append(failure)
        
        root_causes = []
        
        for error_type, group in error_groups.items():
            if len(group) > 1 and self.ai_enabled:  # Multiple tests with same error
                try:
                    prompt = f"""Multiple tests failed with similar errors:

Error Type: {error_type}
Number of Failed Tests: {len(group)}
Test Names: {', '.join([f.get('name', 'unknown') for f in group[:5]])}
Sample Error: {group[0].get('error', 'No error message')[:200]}

Provide:
1. Root Cause: What is the likely underlying issue?
2. Investigation Steps: What should be checked? (list 2-3 items)
3. Suggested Fix: How to resolve this? (1-2 sentences)
4. Priority: CRITICAL, HIGH, MEDIUM, or LOW

Be concise and actionable."""
                    
                    response = self.client.chat.completions.create(
                        model="gpt-4",
                        messages=[
                            {"role": "system", "content": "You are an expert test automation engineer."},
                            {"role": "user", "content": prompt}
                        ],
                        temperature=0.3,
                        max_tokens=400
                    )
                    
                    content = response.choices[0].message.content
                    
                    root_causes.append({
                        'error_type': error_type,
                        'affected_tests': [f.get('name', 'unknown') for f in group],
                        'count': len(group),
                        'analysis': content,
                        'priority': 'HIGH' if len(group) >= 3 else 'MEDIUM'
                    })
                    
                except Exception as e:
                    print(f"⚠️  Error analyzing root cause for {error_type}: {e}")
        
        return root_causes
    
    def _extract_error_type(self, error_message: str) -> str:
        """Categorize error by type"""
        error_lower = error_message.lower()
        
        if 'timeout' in error_lower:
            return 'TIMEOUT'
        elif 'selector' in error_lower or 'element' in error_lower:
            return 'SELECTOR'
        elif 'network' in error_lower or 'connection' in error_lower:
            return 'NETWORK'
        elif 'assertion' in error_lower or 'expected' in error_lower:
            return 'ASSERTION'
        elif 'permission' in error_lower or 'forbidden' in error_lower:
            return 'PERMISSION'
        else:
            return 'OTHER'
    
    def _detect_flaky_tests(self, historical_data: Dict) -> List[Dict]:
        """Statistical flaky test detection"""
        flaky_tests = []
        
        for test_name, runs in historical_data.items():
            if len(runs) < 5:  # Need minimum history
                continue
            
            # Extract pass/fail pattern
            pattern = [1 if r.get('status') == 'passed' else 0 for r in runs]
            pass_rate = sum(pattern) / len(pattern)
            
            # Flaky if inconsistent (neither always pass nor always fail)
            if 0.2 < pass_rate < 0.8:
                flakiness_score = self._calculate_flakiness_score(pattern)
                
                flaky_tests.append({
                    'test_name': test_name,
                    'flakiness_score': round(flakiness_score, 2),
                    'pass_rate': round(pass_rate * 100, 1),
                    'recent_runs': len(runs),
                    'recommendation': 'QUARANTINE' if flakiness_score > 0.7 else 'MONITOR',
                    'stability_trend': self._analyze_stability_trend(pattern)
                })
        
        # Sort by flakiness score
        flaky_tests.sort(key=lambda x: x['flakiness_score'], reverse=True)
        
        return flaky_tests[:10]  # Top 10 flaky tests
    
    def _calculate_flakiness_score(self, pattern: List[int]) -> float:
        """Calculate flakiness using entropy"""
        if not pattern:
            return 0.0
        
        pass_count = sum(pattern)
        fail_count = len(pattern) - pass_count
        
        if pass_count == 0 or fail_count == 0:
            return 0.0
        
        # Calculate entropy (measure of uncertainty)
        total = len(pattern)
        p_pass = pass_count / total
        p_fail = fail_count / total
        
        ent = entropy([p_pass, p_fail], base=2)
        
        # Normalize to 0-1 range (max entropy for binary is 1.0)
        return float(ent)
    
    def _analyze_stability_trend(self, pattern: List[int]) -> str:
        """Analyze if test is getting more or less stable"""
        if len(pattern) < 6:
            return 'INSUFFICIENT_DATA'
        
        # Compare first half vs second half
        mid = len(pattern) // 2
        first_half = pattern[:mid]
        second_half = pattern[mid:]
        
        first_stability = abs(sum(first_half) / len(first_half) - 0.5)
        second_stability = abs(sum(second_half) / len(second_half) - 0.5)
        
        if second_stability > first_stability + 0.1:
            return 'IMPROVING'
        elif second_stability < first_stability - 0.1:
            return 'DEGRADING'
        else:
            return 'STABLE'
    
    def _detect_performance_anomalies(self, performance_data: List[Dict]) -> List[Dict]:
        """Detect performance anomalies using statistical methods"""
        if len(performance_data) < 10:
            return []
        
        try:
            # Extract durations
            durations = np.array([[t.get('duration', 0)] for t in performance_data])
            
            # Use Isolation Forest for anomaly detection
            clf = IsolationForest(contamination=0.1, random_state=42)
            predictions = clf.fit_predict(durations)
            
            median_duration = np.median(durations)
            anomalies = []
            
            for idx, pred in enumerate(predictions):
                if pred == -1:  # Anomaly detected
                    test = performance_data[idx]
                    duration = test.get('duration', 0)
                    deviation = ((duration - median_duration) / median_duration) * 100
                    
                    anomalies.append({
                        'test_name': test.get('name', 'unknown'),
                        'duration_ms': duration,
                        'baseline_ms': int(median_duration),
                        'deviation_percent': round(deviation, 1),
                        'severity': 'HIGH' if abs(deviation) > 100 else 'MEDIUM'
                    })
            
            return sorted(anomalies, key=lambda x: abs(x['deviation_percent']), reverse=True)
            
        except Exception as e:
            print(f"⚠️  Error detecting performance anomalies: {e}")
            return []
    
    def _generate_recommendations(self, test_results: Dict) -> List[Dict]:
        """Generate actionable recommendations"""
        recommendations = []
        
        pass_rate = test_results.get('pass_rate', 100)
        failed_count = test_results.get('failed_tests', 0)
        
        # High failure rate
        if pass_rate < 70:
            recommendations.append({
                'type': 'ACTION',
                'priority': 1,
                'title': '🚨 Critical: High Failure Rate',
                'description': f'Pass rate is only {pass_rate}%. Immediate investigation required.',
                'impact': 'CRITICAL',
                'actionable_steps': [
                    'Review all failed tests immediately',
                    'Check for infrastructure issues',
                    'Consider blocking deployment'
                ]
            })
        elif pass_rate < 85:
            recommendations.append({
                'type': 'ACTION',
                'priority': 2,
                'title': '⚠️ Warning: Below Target Pass Rate',
                'description': f'Pass rate is {pass_rate}%. Target is 95%+.',
                'impact': 'HIGH',
                'actionable_steps': [
                    'Investigate failed tests',
                    'Review recent code changes',
                    'Consider delaying deployment'
                ]
            })
        
        # Flaky tests
        if self.analysis_results.get('flaky_tests'):
            flaky_count = len(self.analysis_results['flaky_tests'])
            recommendations.append({
                'type': 'MONITORING',
                'priority': 3,
                'title': f'📊 {flaky_count} Flaky Test(s) Detected',
                'description': 'Tests showing inconsistent pass/fail behavior',
                'impact': 'MEDIUM',
                'actionable_steps': [
                    'Review and fix flaky tests',
                    'Consider quarantining unstable tests',
                    'Add retry logic for genuinely flaky scenarios'
                ]
            })
        
        # Performance issues
        if self.analysis_results.get('performance_anomalies'):
            recommendations.append({
                'type': 'INVESTIGATION',
                'priority': 4,
                'title': '⚡ Performance Anomalies Detected',
                'description': 'Some tests running significantly slower than baseline',
                'impact': 'MEDIUM',
                'actionable_steps': [
                    'Profile slow tests',
                    'Check for resource constraints',
                    'Review recent performance changes'
                ]
            })
        
        return recommendations
    
    def _generate_summary(self, test_results: Dict) -> Dict:
        """Generate overall analysis summary"""
        failed_count = len(self.analysis_results.get('failure_categorization', []))
        flaky_count = len(self.analysis_results.get('flaky_tests', []))
        anomaly_count = len(self.analysis_results.get('performance_anomalies', []))
        root_cause_count = len(self.analysis_results.get('root_cause_analysis', []))
        
        pass_rate = test_results.get('pass_rate', 100)
        
        # Calculate health score
        health_score = self._calculate_health_score(pass_rate, flaky_count, anomaly_count)
        
        # Determine trend
        trend = 'STABLE'
        if pass_rate < 70:
            trend = 'CRITICAL'
        elif pass_rate < 85:
            trend = 'DEGRADING'
        elif pass_rate >= 95:
            trend = 'EXCELLENT'
        
        return {
            'total_failures_analyzed': failed_count,
            'flaky_tests_detected': flaky_count,
            'performance_anomalies': anomaly_count,
            'root_causes_identified': root_cause_count,
            'overall_health_score': health_score,
            'trend': trend,
            'pass_rate': pass_rate,
            'ai_enabled': self.ai_enabled
        }
    
    def _calculate_health_score(self, pass_rate: float, flaky_count: int, anomaly_count: int) -> int:
        """Calculate overall test suite health score (0-100)"""
        score = pass_rate
        
        # Penalties
        score -= flaky_count * 2  # -2 points per flaky test
        score -= anomaly_count * 1  # -1 point per anomaly
        
        return max(0, min(100, int(score)))


def load_test_results(metrics_path: str) -> Dict:
    """Load test results from metrics.json"""
    try:
        with open(metrics_path, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"⚠️  Metrics file not found: {metrics_path}")
        return {}
    except json.JSONDecodeError as e:
        print(f"⚠️  Error parsing metrics JSON: {e}")
        return {}


def load_historical_data(history_path: str) -> Optional[Dict]:
    """Load historical test data if available"""
    try:
        with open(history_path, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"ℹ️  No historical data found at {history_path}")
        return None
    except json.JSONDecodeError as e:
        print(f"⚠️  Error parsing historical data: {e}")
        return None


def save_analysis_results(results: Dict, output_path: str):
    """Save analysis results to JSON file"""
    try:
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        with open(output_path, 'w') as f:
            json.dump(results, f, indent=2)
        
        print(f"✅ Analysis results saved to: {output_path}")
        
    except Exception as e:
        print(f"❌ Error saving results: {e}")
        sys.exit(1)


def print_summary(results: Dict):
    """Print human-readable summary of analysis"""
    print("\n" + "="*60)
    print("🤖 AI ANALYSIS SUMMARY")
    print("="*60)
    
    summary = results.get('summary', {})
    
    print(f"\n📊 Overall Health Score: {summary.get('overall_health_score', 0)}/100")
    print(f"📈 Trend: {summary.get('trend', 'UNKNOWN')}")
    print(f"✓ Pass Rate: {summary.get('pass_rate', 0)}%")
    print(f"🤖 AI Analysis: {'Enabled' if summary.get('ai_enabled') else 'Disabled (statistical only)'}")
    
    print(f"\n📋 Analysis Results:")
    print(f"  - Failures Analyzed: {summary.get('total_failures_analyzed', 0)}")
    print(f"  - Flaky Tests: {summary.get('flaky_tests_detected', 0)}")
    print(f"  - Performance Anomalies: {summary.get('performance_anomalies', 0)}")
    print(f"  - Root Causes: {summary.get('root_causes_identified', 0)}")
    
    # Print recommendations
    recommendations = results.get('recommendations', [])
    if recommendations:
        print(f"\n💡 Top Recommendations:")
        for i, rec in enumerate(recommendations[:3], 1):
            print(f"  {i}. [{rec['type']}] {rec['title']}")
    
    print("\n" + "="*60 + "\n")


def main():
    """Main execution"""
    print("🚀 AI-Powered Test Analysis")
    print("="*60)
    
    # Paths
    metrics_path = os.path.join('test-summary', 'metrics.json')
    history_path = os.path.join('test-summary', 'historical-data.json')
    output_path = os.path.join('test-summary', 'ai-analysis.json')
    
    # Load data
    print(f"📂 Loading test results from: {metrics_path}")
    test_results = load_test_results(metrics_path)
    
    if not test_results:
        print("❌ No test results found. Exiting.")
        sys.exit(1)
    
    historical_data = load_historical_data(history_path)
    
    # Initialize analyzer
    api_key = os.getenv('OPENAI_API_KEY')
    analyzer = TestAnalysisAI(openai_api_key=api_key)
    
    # Run analysis
    results = analyzer.analyze(test_results, historical_data)
    
    # Save results
    save_analysis_results(results, output_path)
    
    # Print summary
    print_summary(results)
    
    print("✅ Analysis complete! Check ai-analysis.json for details.")


if __name__ == '__main__':
    main()
