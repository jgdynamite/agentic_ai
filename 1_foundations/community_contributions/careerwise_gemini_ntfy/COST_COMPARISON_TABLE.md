# Cost Comparison Quick Reference Table

## Monthly Costs by Traffic Volume

| Daily Requests | Monthly Requests | Akamai | AWS App Runner | GCP Cloud Run | Winner |
|----------------|------------------|--------|----------------|---------------|--------|
| **1,000** | 30,000 | $73 | $9 | $4 | 🥇 GCP |
| **10,000** | 300,000 | $73 | $28 | $15 | 🥇 GCP |
| **50,000** | 1.5M | $73 | $72 | $21 | 🥇 GCP |
| **100,000** | 3M | $73 | $144 | $42 | 🥇 GCP |
| **500,000** | 15M | $73 | $360 | $105 | 🥇 GCP |
| **1,000,000** | 30M | $146* | $720 | $42 | 🥇 GCP |
| **5,000,000** | 150M | $292* | $3,600 | $210 | 🥇 GCP |
| **10,000,000** | 300M | $584* | $7,200 | $420 | 🥇 GCP |

*Akamai requires larger instance (Medium) for high traffic

---

## Cost per Million Requests

| Platform | Cost per Million Requests | Notes |
|----------|---------------------------|-------|
| **GCP Cloud Run** | **$1.40** | With concurrency=80, optimized |
| **Akamai** | $4.87 | Fixed cost, includes edge network |
| **AWS App Runner** | $24.00 | Instance-based, less efficient |

---

## Cost Breakdown by Component

### At 1M Requests/Day (30M/month)

#### Akamai ($146/month)
```
Compute (Medium Instance): $146.00
Data Transfer: $0.00 (included)
Edge Network: $0.00 (included)
─────────────────────────────
Total: $146.00/month
```

#### AWS App Runner ($720/month)
```
Compute (25 instances avg): $711.75
  - CPU: $584.00
  - Memory: $127.75
Requests: $0.25
Data Transfer: $8.10
─────────────────────────────
Total: $720.10/month
```

#### GCP Cloud Run ($42/month)
```
Compute (with concurrency): $19.88
  - CPU: $18.00
  - Memory: $1.88
Requests: $11.20
Data Transfer: $10.80
─────────────────────────────
Total: $41.88/month
```

---

## Scaling Cost Comparison

### Cost Growth Rate

| Platform | Cost Growth | Scaling Model |
|----------|-------------|---------------|
| **GCP Cloud Run** | Linear (pay per use) | ✅ Best scaling |
| **Akamai** | Step function (instance upgrades) | ⚠️ Fixed tiers |
| **AWS App Runner** | Linear (instance-based) | ⚠️ Less efficient |

### Cost at Different Scales

```
Traffic: 100K → 1M → 10M requests/day

Akamai:    $73 → $146 → $584  (2x, 4x)
AWS:       $72 → $720 → $7,200 (10x, 10x)
GCP:       $21 → $42 → $420   (2x, 10x)
```

**GCP maintains 3-17x cost advantage at all scales**

---

## Geographic Cost Impact

### Data Transfer Costs (90 GB/month at 1M req/day)

| Platform | Data Transfer Cost | Notes |
|----------|-------------------|-------|
| **Akamai** | $0 | Included in edge network |
| **AWS** | $8.10 | $0.09/GB (first 10TB) |
| **GCP** | $10.80 | $0.12/GB (first 10TB) |

**Data transfer is minimal compared to compute costs**

---

## Optimization Impact

### With Optimizations Applied

| Platform | Base Cost | Optimized Cost | Savings |
|----------|-----------|----------------|---------|
| **GCP** | $42 | $25* | 40% |
| **AWS** | $720 | $400-500* | 30-44% |
| **Akamai** | $146 | $146 | 0% (fixed) |

*With CDN caching (50% cache hit rate)

---

## Best Platform by Use Case

### Cost Optimization
🥇 **GCP Cloud Run** - Cheapest at all volumes

### Global Low Latency
🥇 **Akamai** - Best edge network (4,100+ locations)

### AWS Ecosystem Integration
🥇 **AWS App Runner** - Best if already using AWS

### Predictable Budget
🥇 **Akamai** - Fixed cost, no surprises

### Variable Traffic
🥇 **GCP Cloud Run** - Scales to zero, pay per use

---

## Key Takeaways

1. **GCP Cloud Run is cheapest** at all traffic volumes (3-17x cheaper than AWS)
2. **Akamai's fixed cost** becomes competitive at very high volumes
3. **Edge computing** (Akamai) provides significant latency benefits
4. **Concurrency configuration** is critical for GCP cost optimization
5. **Data transfer costs** are minimal compared to compute

---

## Recommendations

### For 1M Requests/Day:
- **Best Overall:** GCP Cloud Run ($42/month)
- **Best for Edge:** Akamai ($146/month, 2.5x more but better latency)
- **Avoid:** AWS App Runner ($720/month, 17x more expensive)

### For 10M+ Requests/Day:
- **Best Overall:** GCP Cloud Run (still cheapest)
- **Consider Akamai:** If global latency is critical
- **AWS:** Only if required for ecosystem integration

---

## Cost Monitoring Tips

1. Set up billing alerts at $50, $100, $200 thresholds
2. Monitor daily request counts
3. Track actual vs estimated costs
4. Review monthly for optimization opportunities
5. Consider reserved capacity for baseline load (AWS)

---

## Next Steps

1. Deploy to GCP Cloud Run with concurrency=80
2. Monitor actual costs for 1 week
3. Compare with estimates
4. Optimize based on actual traffic patterns
5. Consider Akamai if global latency is critical

