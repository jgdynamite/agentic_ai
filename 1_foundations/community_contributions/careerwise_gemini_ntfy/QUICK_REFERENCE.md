# CareerWise Deployment Quick Reference

## 🚀 Quick Start

### 1. Prepare Environment
```bash
cd 1_foundations/community_contributions/careerwise_gemini_ntfy
export GOOGLE_API_KEY="your-key"
export NTFY_TOPIC="your-topic"  # Optional
```

### 2. Build & Test Locally
```bash
./deploy.sh
# Choose option 2: Build and test locally
```

### 3. Deploy to Platform
```bash
# GCP
./deploy.sh  # Choose option 3

# AWS  
./deploy.sh  # Choose option 4

# Akamai
./deploy.sh  # Choose option 5 (shows instructions)
```

---

## 📊 Performance Testing

### Run Tests
```bash
# Edit test_performance.py to add your endpoints
python test_performance.py
```

### Update Endpoints in test_performance.py
```python
ENDPOINTS = {
    "Akamai": "https://your-akamai-endpoint.edgekey.net/chat",
    "AWS": "https://your-aws-endpoint.us-east-1.awsapprunner.com/chat",
    "GCP": "https://your-gcp-endpoint-xxxxx-uc.a.run.app/chat"
}
```

---

## 💰 Cost Tracking

### Monthly Cost Estimate (10,000 requests/day)

| Platform | Monthly Cost | Notes |
|----------|--------------|-------|
| **GCP Cloud Run** | ~$10-16 | Pay per use, scales to zero |
| **AWS App Runner** | ~$9-28 | Pay per use, scales to zero |
| **Akamai** | ~$73 | Fixed cost, includes edge |

### Track Actual Costs
- **GCP:** Cloud Console → Billing
- **AWS:** Cost Explorer → App Runner
- **Akamai:** Control Center → Billing

---

## 🔧 Configuration

### Environment Variables
- `GOOGLE_API_KEY` - Required
- `NTFY_TOPIC` - Optional (for notifications)

### Port
- Default: `8080`
- Change in Dockerfile if needed

### Resources
- **CPU:** 0.5-1 vCPU
- **Memory:** 1 GB
- **Timeout:** 300 seconds (for Gemini API calls)

---

## 📈 Key Metrics to Monitor

1. **Latency**
   - Average response time
   - P95, P99 percentiles
   - Cold start time

2. **Reliability**
   - Success rate
   - Error rate
   - Uptime

3. **Cost**
   - Compute hours
   - Request count
   - Data transfer

4. **Edge Performance**
   - Geographic latency
   - Edge vs origin comparison

---

## 🆘 Troubleshooting

### Issue: Container won't start
- Check environment variables are set
- Verify port 8080 is available
- Check Docker logs: `docker logs <container-id>`

### Issue: API returns errors
- Verify GOOGLE_API_KEY is valid
- Check Gemini API quota
- Review application logs

### Issue: High latency
- Check Gemini API response times
- Verify container resources
- Consider edge deployment (Akamai)

---

## 📚 Documentation

- Full deployment guide: `CLOUD_DEPLOYMENT_COMPARISON.md`
- Performance testing: `test_performance.py`
- Deployment script: `deploy.sh`

---

## 🎯 Next Steps

1. ✅ Deploy to all three platforms
2. ✅ Run performance tests for 1 week
3. ✅ Compare costs and metrics
4. ✅ Document findings
5. ✅ Choose best platform for your use case

