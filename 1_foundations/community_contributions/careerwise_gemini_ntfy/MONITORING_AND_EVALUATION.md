# Monitoring and Evaluation Guide
## Collecting Data and Making Decisions

After deploying to all platforms, use this guide to monitor costs, collect performance data, and make informed decisions.

---

## 📊 Step 1: Set Up Cost Monitoring

### 1.1 GCP Cost Monitoring

**Set Up Billing Alerts:**

```bash
# Create budget
gcloud billing budgets create \
  --billing-account=YOUR_BILLING_ACCOUNT_ID \
  --display-name="CareerWise Budget" \
  --budget-amount=100USD \
  --threshold-rule=percent=50 \
  --threshold-rule=percent=90 \
  --threshold-rule=percent=100 \
  --filter-projects=PROJECT_ID
```

**View Costs:**
- Console: https://console.cloud.google.com/billing
- API: Use Cloud Billing API to export data

**Daily Cost Check Script:**

Create `check-gcp-costs.sh`:

```bash
#!/bin/bash
# Get Cloud Run costs for last 24 hours
gcloud logging read "resource.type=cloud_run_revision" \
  --limit 1000 \
  --format json | \
  jq '[.[] | select(.jsonPayload.message) | .timestamp] | length'
```

### 1.2 AWS Cost Monitoring

**Set Up Budget:**

```bash
# Create budget via AWS CLI
aws budgets create-budget \
  --account-id YOUR_ACCOUNT_ID \
  --budget file://budget.json \
  --notifications-with-subscribers file://notifications.json
```

**budget.json:**
```json
{
  "BudgetName": "CareerWise-Budget",
  "BudgetLimit": {
    "Amount": "100",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST",
  "CostFilters": {
    "Service": ["AWS App Runner"]
  }
}
```

**View Costs:**
- Console: https://console.aws.amazon.com/cost-management/home
- Cost Explorer: Filter by App Runner service

**Daily Cost Check:**

```bash
# Get App Runner costs
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-02 \
  --granularity DAILY \
  --metrics BlendedCost \
  --filter file://filter.json
```

### 1.3 Akamai Cost Monitoring

**View Costs:**
- Control Center: https://control.akamai.com → Billing
- Fixed monthly cost (predictable)
- No per-request charges

**Track Usage:**
- Monitor compute instance hours
- Track data transfer (if applicable)

---

## 📈 Step 2: Performance Data Collection

### 2.1 Automated Performance Testing

**Run Daily Tests:**

```bash
# Update test_performance.py with your endpoints first
python test_performance.py > performance-$(date +%Y%m%d).log

# Or schedule daily
# Add to crontab:
# 0 2 * * * cd /path/to/careerwise && python test_performance.py >> performance.log
```

### 2.2 Geographic Performance Testing

**Test from Multiple Locations:**

Use services like:
- **Pingdom:** https://www.pingdom.com
- **GTmetrix:** https://gtmetrix.com
- **WebPageTest:** https://www.webpagetest.org

**Or use curl from different regions:**

```bash
# Test from different regions (if you have access)
# US
curl -w "@curl-format.txt" -o /dev/null -s $GCP_URL/chat

# Europe (if you have EU endpoint)
curl -w "@curl-format.txt" -o /dev/null -s $GCP_URL_EU/chat
```

**curl-format.txt:**
```
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
```

### 2.3 Load Testing

**Use Apache Bench or wrk:**

```bash
# Install wrk
brew install wrk  # Mac
# or
sudo apt-get install wrk  # Linux

# Run load test
wrk -t4 -c100 -d30s -s post.lua $GCP_URL/chat

# post.lua:
wrk.method = "POST"
wrk.body = '{"message": "Hello", "history": []}'
wrk.headers["Content-Type"] = "application/json"
```

---

## 📝 Step 3: Data Collection Template

### 3.1 Daily Data Collection

Create `collect-daily-data.sh`:

```bash
#!/bin/bash
# Daily data collection script

DATE=$(date +%Y-%m-%d)
LOG_DIR="data-collection"

mkdir -p $LOG_DIR

# Performance test
python test_performance.py > $LOG_DIR/performance-$DATE.json

# Cost data (manual - copy from consoles)
echo "Please record costs from each platform console"
echo "Date: $DATE" >> $LOG_DIR/costs-$DATE.txt
echo "GCP: $" >> $LOG_DIR/costs-$DATE.txt
echo "AWS: $" >> $LOG_DIR/costs-$DATE.txt
echo "Akamai: $" >> $LOG_DIR/costs-$DATE.txt
```

### 3.2 Weekly Summary

Create `weekly-summary.py`:

```python
#!/usr/bin/env python3
import json
import glob
from datetime import datetime, timedelta

def generate_weekly_summary():
    # Collect all performance data from the week
    files = glob.glob("data-collection/performance-*.json")
    
    summary = {
        "week_start": (datetime.now() - timedelta(days=7)).strftime("%Y-%m-%d"),
        "week_end": datetime.now().strftime("%Y-%m-%d"),
        "platforms": {}
    }
    
    # Process performance data
    for file in files:
        with open(file) as f:
            data = json.load(f)
            # Aggregate metrics
    
    # Write summary
    with open("weekly-summary.json", "w") as f:
        json.dump(summary, f, indent=2)
    
    print("Weekly summary generated")

if __name__ == "__main__":
    generate_weekly_summary()
```

---

## 📊 Step 4: Evaluation Framework

### 4.1 Cost Evaluation

**Create `evaluate-costs.py`:**

```python
#!/usr/bin/env python3
"""
Cost Evaluation Script
Compares costs across platforms and calculates cost per million requests
"""

import json
from datetime import datetime

def evaluate_costs():
    # Load cost data
    with open("data-collection/costs.json") as f:
        costs = json.load(f)
    
    # Load request counts
    with open("data-collection/requests.json") as f:
        requests = json.load(f)
    
    results = {}
    
    for platform in ["GCP", "AWS", "Akamai"]:
        monthly_cost = costs[platform]["monthly"]
        monthly_requests = requests[platform]["monthly"]
        
        cost_per_million = (monthly_cost / monthly_requests) * 1_000_000 if monthly_requests > 0 else 0
        
        results[platform] = {
            "monthly_cost": monthly_cost,
            "monthly_requests": monthly_requests,
            "cost_per_million": cost_per_million
        }
    
    # Find winner
    winner = min(results.items(), key=lambda x: x[1]["cost_per_million"])
    
    print("Cost Evaluation Results:")
    print("=" * 60)
    for platform, data in results.items():
        print(f"{platform}:")
        print(f"  Monthly Cost: ${data['monthly_cost']:.2f}")
        print(f"  Monthly Requests: {data['monthly_requests']:,}")
        print(f"  Cost per Million: ${data['cost_per_million']:.2f}")
        print()
    
    print(f"Winner (Cost): {winner[0]} at ${winner[1]['cost_per_million']:.2f} per million")
    
    return results

if __name__ == "__main__":
    evaluate_costs()
```

### 4.2 Performance Evaluation

**Create `evaluate-performance.py`:**

```python
#!/usr/bin/env python3
"""
Performance Evaluation Script
Compares latency and reliability across platforms
"""

import json
import statistics

def evaluate_performance():
    # Load performance data
    with open("data-collection/performance.json") as f:
        perf_data = json.load(f)
    
    results = {}
    
    for platform in ["GCP", "AWS", "Akamai"]:
        latencies = perf_data[platform]["latencies"]
        
        results[platform] = {
            "avg_latency": statistics.mean(latencies),
            "p95_latency": statistics.quantiles(latencies, n=20)[18],
            "p99_latency": statistics.quantiles(latencies, n=100)[98],
            "min_latency": min(latencies),
            "max_latency": max(latencies),
            "success_rate": perf_data[platform]["success_rate"]
        }
    
    # Find winner
    winner_latency = min(results.items(), key=lambda x: x[1]["avg_latency"])
    winner_reliability = max(results.items(), key=lambda x: x[1]["success_rate"])
    
    print("Performance Evaluation Results:")
    print("=" * 60)
    for platform, data in results.items():
        print(f"{platform}:")
        print(f"  Avg Latency: {data['avg_latency']:.2f}ms")
        print(f"  P95 Latency: {data['p95_latency']:.2f}ms")
        print(f"  P99 Latency: {data['p99_latency']:.2f}ms")
        print(f"  Success Rate: {data['success_rate']:.2f}%")
        print()
    
    print(f"Winner (Latency): {winner_latency[0]} at {winner_latency[1]['avg_latency']:.2f}ms avg")
    print(f"Winner (Reliability): {winner_reliability[0]} at {winner_reliability[1]['success_rate']:.2f}%")
    
    return results

if __name__ == "__main__":
    evaluate_performance()
```

### 4.3 Combined Evaluation

**Create `final-evaluation.md` template:**

```markdown
# Final Evaluation Report
## Date: [DATE]

## Cost Comparison

| Platform | Monthly Cost | Cost per Million | Winner |
|----------|--------------|------------------|--------|
| GCP | $ | $ | |
| AWS | $ | $ | |
| Akamai | $ | $ | |

**Cost Winner:** [PLATFORM]

## Performance Comparison

| Platform | Avg Latency | P95 Latency | Success Rate | Winner |
|----------|-------------|-------------|--------------|--------|
| GCP | ms | ms | % | |
| AWS | ms | ms | % | |
| Akamai | ms | ms | % | |

**Performance Winner:** [PLATFORM]

## Edge Computing Value

- Geographic latency improvement: [X]ms
- Business impact: [DESCRIPTION]
- ROI: [CALCULATION]

## Total Cost of Ownership

| Platform | Infrastructure | Management | Security | Total | Winner |
|----------|---------------|------------|----------|-------|--------|
| GCP | $ | $ | $ | $ | |
| AWS | $ | $ | $ | $ | |
| Akamai | $ | $ | $ | $ | |

**TCO Winner:** [PLATFORM]

## Final Recommendation

**Best Platform:** [PLATFORM]

**Reasoning:**
- [REASON 1]
- [REASON 2]
- [REASON 3]

## Next Steps

1. [ACTION 1]
2. [ACTION 2]
3. [ACTION 3]
```

---

## 🎯 Step 5: Decision Framework

### 5.1 Scoring Matrix

Create `decision-matrix.py`:

```python
#!/usr/bin/env python3
"""
Decision Matrix
Scores platforms based on multiple criteria
"""

def score_platforms():
    # Load evaluation data
    with open("evaluation-results.json") as f:
        data = json.load(f)
    
    # Weights (adjust based on priorities)
    weights = {
        "cost": 0.4,      # 40% weight on cost
        "performance": 0.3,  # 30% weight on performance
        "reliability": 0.2,  # 20% weight on reliability
        "edge_benefits": 0.1  # 10% weight on edge benefits
    }
    
    scores = {}
    
    for platform in ["GCP", "AWS", "Akamai"]:
        # Normalize scores (0-100 scale)
        cost_score = 100 - (data[platform]["cost_per_million"] / 50 * 100)  # Lower is better
        perf_score = 100 - (data[platform]["avg_latency"] / 10 * 100)  # Lower is better
        rel_score = data[platform]["success_rate"]  # Higher is better
        edge_score = data[platform].get("edge_score", 0)  # Custom scoring
        
        # Calculate weighted score
        total_score = (
            cost_score * weights["cost"] +
            perf_score * weights["performance"] +
            rel_score * weights["reliability"] +
            edge_score * weights["edge_benefits"]
        )
        
        scores[platform] = {
            "cost_score": cost_score,
            "perf_score": perf_score,
            "rel_score": rel_score,
            "edge_score": edge_score,
            "total_score": total_score
        }
    
    # Find winner
    winner = max(scores.items(), key=lambda x: x[1]["total_score"])
    
    print("Platform Scores:")
    print("=" * 60)
    for platform, score_data in scores.items():
        print(f"{platform}:")
        print(f"  Cost Score: {score_data['cost_score']:.2f}")
        print(f"  Performance Score: {score_data['perf_score']:.2f}")
        print(f"  Reliability Score: {score_data['rel_score']:.2f}")
        print(f"  Edge Score: {score_data['edge_score']:.2f}")
        print(f"  Total Score: {score_data['total_score']:.2f}")
        print()
    
    print(f"Winner: {winner[0]} with score {winner[1]['total_score']:.2f}")
    
    return scores

if __name__ == "__main__":
    score_platforms()
```

---

## 📅 Step 6: Weekly Review Process

### 6.1 Weekly Checklist

- [ ] Collect cost data from all platforms
- [ ] Run performance tests
- [ ] Update evaluation spreadsheets
- [ ] Review trends and anomalies
- [ ] Document findings
- [ ] Adjust monitoring if needed

### 6.2 Monthly Review

- [ ] Generate monthly cost report
- [ ] Calculate cost per million requests
- [ ] Compare with estimates
- [ ] Evaluate edge computing ROI
- [ ] Make platform decision
- [ ] Document lessons learned

---

## 🎯 Final Decision Template

After collecting data for 1-2 weeks, use this template:

```markdown
# Platform Decision Report
## Date: [DATE]
## Evaluation Period: [START] to [END]

## Executive Summary
[2-3 sentence summary of findings and recommendation]

## Data Summary

### Traffic Volume
- Average daily requests: [NUMBER]
- Peak daily requests: [NUMBER]
- Monthly requests: [NUMBER]

### Cost Analysis
- GCP: $[AMOUNT]/month = $[AMOUNT] per million requests
- AWS: $[AMOUNT]/month = $[AMOUNT] per million requests
- Akamai: $[AMOUNT]/month = $[AMOUNT] per million requests

### Performance Analysis
- GCP: [AVG]ms avg, [P95]ms P95, [SUCCESS]% success
- AWS: [AVG]ms avg, [P95]ms P95, [SUCCESS]% success
- Akamai: [AVG]ms avg, [P95]ms P95, [SUCCESS]% success

## Recommendation

**Selected Platform:** [PLATFORM]

**Rationale:**
1. [REASON 1]
2. [REASON 2]
3. [REASON 3]

## Next Steps
1. [ACTION 1]
2. [ACTION 2]
3. [ACTION 3]
```

---

This framework will help you collect real data and make an informed decision based on actual costs and performance metrics.

