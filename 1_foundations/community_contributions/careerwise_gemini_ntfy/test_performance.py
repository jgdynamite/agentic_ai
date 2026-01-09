#!/usr/bin/env python3
"""
Performance Testing Script for CareerWise Chatbot
Tests endpoints across Akamai, AWS, and GCP deployments
"""

import time
import requests
import statistics
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import Dict, List, Tuple
import json
import sys

# Configure your endpoints here
ENDPOINTS = {
    "Akamai": "https://your-akamai-endpoint.edgekey.net/chat",
    "AWS": "https://your-aws-endpoint.us-east-1.awsapprunner.com/chat",
    "GCP": "https://your-gcp-endpoint-xxxxx-uc.a.run.app/chat"
}

TEST_PAYLOAD = {
    "message": "Tell me about your experience and skills",
    "history": []
}

HEADERS = {
    "Content-Type": "application/json"
}

TIMEOUT = 30  # seconds


class PerformanceTest:
    def __init__(self, endpoint_name: str, endpoint_url: str):
        self.endpoint_name = endpoint_name
        self.endpoint_url = endpoint_url
        self.latencies: List[float] = []
        self.errors: List[str] = []
        self.status_codes: List[int] = []

    def make_request(self) -> Tuple[bool, float, int]:
        """Make a single request and return (success, latency_ms, status_code)"""
        try:
            start = time.time()
            response = requests.post(
                self.endpoint_url,
                json=TEST_PAYLOAD,
                headers=HEADERS,
                timeout=TIMEOUT
            )
            latency = (time.time() - start) * 1000  # Convert to milliseconds
            self.status_codes.append(response.status_code)
            
            if response.status_code == 200:
                return True, latency, response.status_code
            else:
                error_msg = f"HTTP {response.status_code}: {response.text[:100]}"
                self.errors.append(error_msg)
                return False, latency, response.status_code
        except requests.exceptions.Timeout:
            self.errors.append("Timeout")
            return False, TIMEOUT * 1000, 0
        except requests.exceptions.RequestException as e:
            self.errors.append(str(e))
            return False, 0, 0

    def run_sequential_test(self, num_requests: int = 10) -> Dict:
        """Run sequential requests"""
        print(f"\n{'='*60}")
        print(f"Sequential Test: {self.endpoint_name}")
        print(f"{'='*60}")
        print(f"Endpoint: {self.endpoint_url}")
        print(f"Requests: {num_requests}")
        
        self.latencies = []
        self.errors = []
        self.status_codes = []
        
        for i in range(num_requests):
            success, latency, status_code = self.make_request()
            if success:
                self.latencies.append(latency)
            print(f"  Request {i+1}/{num_requests}: {latency:.2f}ms (Status: {status_code})", end='\r')
        
        print()  # New line after progress
        return self._calculate_stats()

    def run_concurrent_test(self, num_requests: int = 10, max_workers: int = 10) -> Dict:
        """Run concurrent requests"""
        print(f"\n{'='*60}")
        print(f"Concurrent Test: {self.endpoint_name}")
        print(f"{'='*60}")
        print(f"Endpoint: {self.endpoint_url}")
        print(f"Requests: {num_requests} (Concurrent: {max_workers})")
        
        self.latencies = []
        self.errors = []
        self.status_codes = []
        
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            futures = {executor.submit(self.make_request): i for i in range(num_requests)}
            
            completed = 0
            for future in as_completed(futures):
                completed += 1
                success, latency, status_code = future.result()
                if success:
                    self.latencies.append(latency)
                print(f"  Completed: {completed}/{num_requests}", end='\r')
        
        print()  # New line after progress
        return self._calculate_stats()

    def run_cold_start_test(self) -> Dict:
        """Test cold start (first request after idle)"""
        print(f"\n{'='*60}")
        print(f"Cold Start Test: {self.endpoint_name}")
        print(f"{'='*60}")
        print("Waiting 5 minutes for service to scale to zero...")
        print("(In production, you'd wait for actual scale-to-zero)")
        
        # First request (cold start)
        print("\nMaking first request (cold start)...")
        start = time.time()
        success, latency, status_code = self.make_request()
        cold_start_latency = (time.time() - start) * 1000
        
        if success:
            print(f"  Cold Start Latency: {cold_start_latency:.2f}ms")
        else:
            print(f"  Cold Start Failed: {self.errors[-1] if self.errors else 'Unknown error'}")
        
        # Second request (warm)
        time.sleep(2)
        print("\nMaking second request (warm)...")
        start = time.time()
        success, latency, status_code = self.make_request()
        warm_latency = (time.time() - start) * 1000
        
        if success:
            print(f"  Warm Latency: {warm_latency:.2f}ms")
            print(f"  Cold Start Overhead: {cold_start_latency - warm_latency:.2f}ms")
        else:
            print(f"  Warm Request Failed: {self.errors[-1] if self.errors else 'Unknown error'}")
        
        return {
            "cold_start_latency": cold_start_latency,
            "warm_latency": warm_latency,
            "overhead": cold_start_latency - warm_latency if success else None
        }

    def _calculate_stats(self) -> Dict:
        """Calculate statistics from collected latencies"""
        if not self.latencies:
            return {
                "success_rate": 0.0,
                "total_requests": len(self.status_codes),
                "errors": len(self.errors),
                "error_messages": self.errors[:5]  # First 5 errors
            }
        
        sorted_latencies = sorted(self.latencies)
        total_requests = len(self.status_codes)
        successful_requests = len(self.latencies)
        
        stats = {
            "total_requests": total_requests,
            "successful_requests": successful_requests,
            "failed_requests": total_requests - successful_requests,
            "success_rate": (successful_requests / total_requests * 100) if total_requests > 0 else 0,
            "avg_latency": statistics.mean(self.latencies),
            "min_latency": min(self.latencies),
            "max_latency": max(self.latencies),
            "median_latency": statistics.median(self.latencies),
            "p95_latency": self._percentile(self.latencies, 95),
            "p99_latency": self._percentile(self.latencies, 99),
            "std_dev": statistics.stdev(self.latencies) if len(self.latencies) > 1 else 0,
            "errors": len(self.errors),
            "error_messages": self.errors[:5] if self.errors else []
        }
        
        return stats

    def _percentile(self, data: List[float], percentile: int) -> float:
        """Calculate percentile"""
        if not data:
            return 0.0
        sorted_data = sorted(data)
        index = int(len(sorted_data) * percentile / 100)
        return sorted_data[min(index, len(sorted_data) - 1)]

    def print_stats(self, stats: Dict, test_type: str = ""):
        """Print formatted statistics"""
        print(f"\n{test_type} Results for {self.endpoint_name}:")
        print("-" * 60)
        
        if "success_rate" in stats:
            print(f"Success Rate: {stats['success_rate']:.2f}%")
            print(f"Total Requests: {stats['total_requests']}")
            print(f"Successful: {stats['successful_requests']}")
            print(f"Failed: {stats['failed_requests']}")
            
            if stats['successful_requests'] > 0:
                print(f"\nLatency Statistics:")
                print(f"  Average: {stats['avg_latency']:.2f}ms")
                print(f"  Median: {stats['median_latency']:.2f}ms")
                print(f"  Min: {stats['min_latency']:.2f}ms")
                print(f"  Max: {stats['max_latency']:.2f}ms")
                print(f"  P95: {stats['p95_latency']:.2f}ms")
                print(f"  P99: {stats['p99_latency']:.2f}ms")
                print(f"  Std Dev: {stats['std_dev']:.2f}ms")
        
        if stats.get('errors', 0) > 0:
            print(f"\nErrors: {stats['errors']}")
            if stats.get('error_messages'):
                print("Sample Errors:")
                for error in stats['error_messages']:
                    print(f"  - {error}")


def main():
    """Main test execution"""
    print("=" * 60)
    print("CareerWise Chatbot Performance Test")
    print("=" * 60)
    print("\nMake sure to update ENDPOINTS dictionary with your actual URLs!")
    print("\nPress Enter to continue or Ctrl+C to exit...")
    
    try:
        input()
    except KeyboardInterrupt:
        print("\nExiting...")
        sys.exit(0)
    
    results = {}
    
    # Test each endpoint
    for name, url in ENDPOINTS.items():
        if "your-" in url or "xxxxx" in url:
            print(f"\n⚠️  Skipping {name} - URL not configured")
            continue
        
        test = PerformanceTest(name, url)
        
        # Sequential test
        seq_stats = test.run_sequential_test(num_requests=20)
        test.print_stats(seq_stats, "Sequential")
        results[f"{name}_sequential"] = seq_stats
        
        # Concurrent test
        conc_stats = test.run_concurrent_test(num_requests=20, max_workers=10)
        test.print_stats(conc_stats, "Concurrent")
        results[f"{name}_concurrent"] = conc_stats
        
        # Cold start test (optional - comment out if not needed)
        # cold_stats = test.run_cold_start_test()
        # results[f"{name}_cold_start"] = cold_stats
    
    # Summary comparison
    print("\n" + "=" * 60)
    print("SUMMARY COMPARISON")
    print("=" * 60)
    
    print("\nSequential Test Results:")
    print(f"{'Platform':<15} {'Avg Latency':<15} {'P95 Latency':<15} {'Success Rate':<15}")
    print("-" * 60)
    for name, url in ENDPOINTS.items():
        key = f"{name}_sequential"
        if key in results and results[key].get('successful_requests', 0) > 0:
            stats = results[key]
            print(f"{name:<15} {stats['avg_latency']:>10.2f}ms  {stats['p95_latency']:>10.2f}ms  {stats['success_rate']:>12.2f}%")
    
    print("\nConcurrent Test Results:")
    print(f"{'Platform':<15} {'Avg Latency':<15} {'P95 Latency':<15} {'Success Rate':<15}")
    print("-" * 60)
    for name, url in ENDPOINTS.items():
        key = f"{name}_concurrent"
        if key in results and results[key].get('successful_requests', 0) > 0:
            stats = results[key]
            print(f"{name:<15} {stats['avg_latency']:>10.2f}ms  {stats['p95_latency']:>10.2f}ms  {stats['success_rate']:>12.2f}%")
    
    # Save results to JSON
    with open('performance_results.json', 'w') as f:
        json.dump(results, f, indent=2)
    
    print("\n✅ Results saved to performance_results.json")


if __name__ == "__main__":
    main()

