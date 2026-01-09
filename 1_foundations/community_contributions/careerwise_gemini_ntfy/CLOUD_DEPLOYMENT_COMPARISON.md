# CareerWise Cloud Deployment Comparison Guide
## Akamai vs AWS vs GCP

This guide provides step-by-step instructions for deploying the CareerWise chatbot on three cloud platforms and comparing their performance, costs, and edge computing capabilities.

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Pre-Deployment Setup](#pre-deployment-setup)
3. [Akamai Deployment](#akamai-deployment)
4. [AWS Deployment](#aws-deployment)
5. [GCP Deployment](#gcp-deployment)
6. [Performance Testing](#performance-testing)
7. [Cost Comparison](#cost-comparison)
8. [Edge Computing Analysis](#edge-computing-analysis)
9. [Monitoring & Metrics](#monitoring--metrics)

---

## 🎯 Project Overview

**CareerWise Chatbot:**
- **Framework:** FastAPI
- **Port:** 8080
- **Dependencies:** Python 3.10, FastAPI, Uvicorn, OpenAI SDK (Gemini), PyPDF
- **Container Size:** ~150MB (estimated)
- **API Endpoint:** POST `/chat`
- **External APIs:** Google Gemini API, ntfy.sh

**Key Characteristics:**
- Stateless API (perfect for edge/serverless)
- Async FastAPI (good for concurrent requests)
- Lightweight container
- No database required

---

## 🔧 Pre-Deployment Setup

### 1. Fix Requirements File

The project has `requirements` instead of `requirements.txt`. Create the proper file:

```bash
cd 1_foundations/community_contributions/careerwise_gemini_ntfy
cp requirements requirements.txt
```

### 2. Update Dockerfile (if needed)

Ensure the Dockerfile uses `requirements.txt`:

```dockerfile
FROM python:3.10-slim

WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose port
EXPOSE 8080

# Command to run the FastAPI app with Uvicorn
CMD ["uvicorn", "backend_api:app", "--host", "0.0.0.0", "--port", "8080"]
```

### 3. Environment Variables

You'll need these for all platforms:
- `GOOGLE_API_KEY` - Your Google Gemini API key
- `NTFY_TOPIC` - Your ntfy topic name (optional)

### 4. Test Locally First

```bash
# Build and test locally
docker build -t careerwise-chatbot .
docker run -p 8080:8080 \
  -e GOOGLE_API_KEY="your-key" \
  -e NTFY_TOPIC="your-topic" \
  careerwise-chatbot

# Test the endpoint
curl -X POST http://localhost:8080/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello", "history": []}'
```

---

## 🌐 Akamai Deployment

### Option 1: Akamai Cloud Compute (Recommended)

Akamai's Cloud Compute is their IaaS platform, similar to AWS EC2 or GCP Compute Engine.

#### Step 1: Prepare Container Image

```bash
# Build Docker image
docker build -t careerwise-chatbot:latest .

# Tag for Akamai Container Registry (if available)
# Or use Docker Hub as intermediary
docker tag careerwise-chatbot:latest your-dockerhub-username/careerwise-chatbot:latest
docker push your-dockerhub-username/careerwise-chatbot:latest
```

#### Step 2: Deploy via Akamai Control Center

1. **Access Akamai Control Center**
   - Log in to https://control.akamai.com
   - Navigate to Cloud Compute section

2. **Create Compute Instance**
   - Choose container-based deployment
   - Select your container image
   - Configure:
     - **Instance Type:** Small (1 vCPU, 2GB RAM) - sufficient for this app
     - **Region:** Choose closest to your users
     - **Port:** 8080
     - **Environment Variables:**
       - `GOOGLE_API_KEY`
       - `NTFY_TOPIC`

3. **Configure Load Balancer**
   - Set up Akamai Load Balancer
   - Configure health checks: `GET /docs` (FastAPI auto-generated)
   - Enable edge caching (if applicable)

#### Step 3: Configure Edge Hostname

1. Create edge hostname in Akamai Control Center
2. Point to your compute instance
3. Configure SSL certificate
4. Note the public URL

**Expected URL Format:**
```
https://careerwise-chatbot.yourdomain.edgekey.net
```

### Option 2: Akamai EdgeWorkers (JavaScript - Not Applicable)

EdgeWorkers run JavaScript at the edge. Since this is a Python FastAPI app, EdgeWorkers is not suitable. Use Cloud Compute instead.

### Akamai Configuration Summary

| Setting | Value |
|---------|-------|
| **Service Type** | Cloud Compute (IaaS) |
| **Container Image** | Docker Hub or Akamai Registry |
| **Instance Size** | Small (1 vCPU, 2GB RAM) |
| **Port** | 8080 |
| **Health Check** | `/docs` endpoint |
| **Edge Caching** | Disabled (API responses are dynamic) |
| **SSL** | Akamai-managed certificate |

---

## ☁️ AWS Deployment

### Option 1: AWS App Runner (Recommended - Serverless-like)

App Runner is perfect for containerized applications with automatic scaling.

#### Step 1: Push Image to ECR

```bash
# Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Create ECR repository
aws ecr create-repository --repository-name careerwise-chatbot --region us-east-1

# Tag and push
docker tag careerwise-chatbot:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/careerwise-chatbot:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/careerwise-chatbot:latest
```

#### Step 2: Create App Runner Service

**Via AWS Console:**
1. Go to AWS App Runner
2. Create service
3. Source: ECR
4. Select your image
5. Configure:
   - **CPU:** 0.5 vCPU
   - **Memory:** 1 GB
   - **Port:** 8080
   - **Environment Variables:**
     - `GOOGLE_API_KEY`
     - `NTFY_TOPIC`
   - **Auto Scaling:** Enabled (1-10 instances)

**Via AWS CLI:**
```bash
aws apprunner create-service \
  --service-name careerwise-chatbot \
  --source-configuration '{
    "ImageRepository": {
      "ImageIdentifier": "<account-id>.dkr.ecr.us-east-1.amazonaws.com/careerwise-chatbot:latest",
      "ImageRepositoryType": "ECR",
      "ImageConfiguration": {
        "Port": "8080",
        "RuntimeEnvironmentVariables": {
          "GOOGLE_API_KEY": "your-key",
          "NTFY_TOPIC": "your-topic"
        }
      }
    },
    "AutoDeploymentsEnabled": true
  }' \
  --instance-configuration '{
    "Cpu": "0.5 vCPU",
    "Memory": "1 GB"
  }' \
  --auto-scaling-configuration-arn <auto-scaling-arn>
```

**Expected URL:**
```
https://xxxxx.us-east-1.awsapprunner.com
```

### Option 2: AWS ECS Fargate (Alternative)

For more control over infrastructure:

```bash
# Create ECS cluster
aws ecs create-cluster --cluster-name careerwise-cluster

# Create task definition
aws ecs register-task-definition \
  --family careerwise-chatbot \
  --network-mode awsvpc \
  --requires-compatibilities FARGATE \
  --cpu 512 \
  --memory 1024 \
  --container-definitions '[
    {
      "name": "careerwise-chatbot",
      "image": "<account-id>.dkr.ecr.us-east-1.amazonaws.com/careerwise-chatbot:latest",
      "portMappings": [{"containerPort": 8080}],
      "environment": [
        {"name": "GOOGLE_API_KEY", "value": "your-key"},
        {"name": "NTFY_TOPIC", "value": "your-topic"}
      ]
    }
  ]'

# Create service
aws ecs create-service \
  --cluster careerwise-cluster \
  --service-name careerwise-service \
  --task-definition careerwise-chatbot \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx],assignPublicIp=ENABLED}"
```

### Option 3: AWS Lambda (Not Recommended)

Lambda has limitations for this use case:
- 15-minute timeout (may be insufficient for Gemini API calls)
- Cold start latency
- Container size limits

**Use App Runner or ECS instead.**

### AWS Configuration Summary

| Setting | App Runner | ECS Fargate |
|---------|------------|-------------|
| **Service Type** | Serverless-like | Container Service |
| **CPU** | 0.5 vCPU | 0.5 vCPU (512 units) |
| **Memory** | 1 GB | 1 GB |
| **Auto Scaling** | Yes | Yes (configure separately) |
| **Cost Model** | Pay per request + compute | Pay per task hour |
| **Best For** | Simple deployment | More control needed |

---

## 🚀 GCP Deployment

### Option 1: Cloud Run (Recommended - Serverless)

Cloud Run is GCP's serverless container platform, similar to AWS App Runner.

#### Step 1: Build and Push to GCR/Artifact Registry

```bash
# Set project
gcloud config set project YOUR_PROJECT_ID

# Build and push to Artifact Registry
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/careerwise-chatbot

# Or use Artifact Registry (newer)
gcloud artifacts repositories create careerwise-repo \
  --repository-format=docker \
  --location=us-central1

gcloud auth configure-docker us-central1-docker.pkg.dev

docker tag careerwise-chatbot:latest \
  us-central1-docker.pkg.dev/YOUR_PROJECT_ID/careerwise-repo/careerwise-chatbot:latest

docker push us-central1-docker.pkg.dev/YOUR_PROJECT_ID/careerwise-repo/careerwise-chatbot:latest
```

#### Step 2: Deploy to Cloud Run

**Via gcloud CLI:**
```bash
gcloud run deploy careerwise-chatbot \
  --image gcr.io/YOUR_PROJECT_ID/careerwise-chatbot \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8080 \
  --memory 1Gi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10 \
  --set-env-vars="GOOGLE_API_KEY=your-key,NTFY_TOPIC=your-topic" \
  --timeout 300
```

**Via GCP Console:**
1. Go to Cloud Run
2. Create service
3. Select container image
4. Configure:
   - **Region:** us-central1 (or closest to users)
   - **CPU:** 1
   - **Memory:** 1 GB
   - **Min instances:** 0 (scale to zero)
   - **Max instances:** 10
   - **Port:** 8080
   - **Environment Variables:** Add GOOGLE_API_KEY and NTFY_TOPIC
   - **Authentication:** Allow unauthenticated (for public API)

**Expected URL:**
```
https://careerwise-chatbot-xxxxx-uc.a.run.app
```

### Option 2: Cloud Run for Anthos (Edge Deployment)

For edge computing with Cloud Run:

```bash
# Deploy to Anthos cluster at edge locations
gcloud run deploy careerwise-chatbot \
  --image gcr.io/YOUR_PROJECT_ID/careerwise-chatbot \
  --platform gke \
  --cluster edge-cluster \
  --cluster-location us-central1 \
  --namespace default
```

### GCP Configuration Summary

| Setting | Cloud Run | Cloud Run for Anthos |
|---------|-----------|----------------------|
| **Service Type** | Serverless | Edge-enabled |
| **CPU** | 1 vCPU | 1 vCPU |
| **Memory** | 1 GB | 1 GB |
| **Min Instances** | 0 (scale to zero) | 1+ |
| **Max Instances** | 10 | 10 |
| **Cost Model** | Pay per request + compute | Pay per node hour |
| **Best For** | Cost optimization | Edge computing |

---

## 📊 Performance Testing

### Test Script

Create `test_performance.sh`:

```bash
#!/bin/bash

# Configuration
ENDPOINTS=(
  "https://careerwise-akamai.edgekey.net/chat"
  "https://xxxxx.us-east-1.awsapprunner.com/chat"
  "https://careerwise-chatbot-xxxxx-uc.a.run.app/chat"
)

TEST_MESSAGE='{"message": "Tell me about your experience", "history": []}'

echo "Performance Test Results"
echo "======================="
echo ""

for endpoint in "${ENDPOINTS[@]}"; do
  echo "Testing: $endpoint"
  
  # Measure latency (10 requests)
  total_time=0
  for i in {1..10}; do
    start=$(date +%s%N)
    curl -s -X POST "$endpoint" \
      -H "Content-Type: application/json" \
      -d "$TEST_MESSAGE" > /dev/null
    end=$(date +%s%N)
    duration=$(( (end - start) / 1000000 ))
    total_time=$((total_time + duration))
  done
  
  avg_latency=$((total_time / 10))
  echo "  Average Latency: ${avg_latency}ms"
  echo ""
done
```

### Python Test Script

Create `test_performance.py`:

```python
import time
import requests
import statistics
from concurrent.futures import ThreadPoolExecutor

ENDPOINTS = {
    "Akamai": "https://careerwise-akamai.edgekey.net/chat",
    "AWS": "https://xxxxx.us-east-1.awsapprunner.com/chat",
    "GCP": "https://careerwise-chatbot-xxxxx-uc.a.run.app/chat"
}

TEST_PAYLOAD = {
    "message": "Tell me about your experience",
    "history": []
}

def test_endpoint(name, url, num_requests=50):
    """Test endpoint performance"""
    latencies = []
    errors = 0
    
    print(f"\nTesting {name} ({url})")
    print("-" * 50)
    
    def make_request():
        try:
            start = time.time()
            response = requests.post(
                url,
                json=TEST_PAYLOAD,
                timeout=30,
                headers={"Content-Type": "application/json"}
            )
            latency = (time.time() - start) * 1000  # Convert to ms
            latencies.append(latency)
            return response.status_code == 200
        except Exception as e:
            print(f"  Error: {e}")
            return False
    
    # Sequential requests
    print("Sequential Requests:")
    for i in range(10):
        make_request()
    
    if latencies:
        print(f"  Avg Latency: {statistics.mean(latencies):.2f}ms")
        print(f"  Min Latency: {min(latencies):.2f}ms")
        print(f"  Max Latency: {max(latencies):.2f}ms")
        print(f"  Median: {statistics.median(latencies):.2f}ms")
        print(f"  P95: {statistics.quantiles(latencies, n=20)[18]:.2f}ms")
    
    # Concurrent requests
    print("\nConcurrent Requests (10 parallel):")
    latencies = []
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = [executor.submit(make_request) for _ in range(10)]
        results = [f.result() for f in futures]
    
    if latencies:
        print(f"  Avg Latency: {statistics.mean(latencies):.2f}ms")
        print(f"  Min Latency: {min(latencies):.2f}ms")
        print(f"  Max Latency: {max(latencies):.2f}ms")

if __name__ == "__main__":
    for name, url in ENDPOINTS.items():
        test_endpoint(name, url)
```

### Metrics to Measure

1. **Latency Metrics:**
   - Time to First Byte (TTFB)
   - Total Response Time
   - P50, P95, P99 percentiles

2. **Throughput:**
   - Requests per second
   - Concurrent request handling

3. **Cold Start:**
   - First request latency (after idle period)
   - Warm-up time

4. **Geographic Performance:**
   - Test from multiple locations
   - Compare edge vs origin latency

---

## 💰 Cost Comparison

### Low Volume (10,000 requests/day)

#### Assumptions
- **Traffic:** 10,000 requests/day = 300,000 requests/month
- **Average Request Duration:** 2 seconds
- **Request Size:** 1 KB request, 2 KB response
- **Data Transfer:** 30 MB/day

### Akamai Cloud Compute

**Pricing Model:**
- Compute instance: ~$0.10/hour (small instance)
- Data transfer: Included in edge network
- Edge benefits: Reduced origin load

**Monthly Cost Estimate:**
```
Compute: $0.10/hour × 730 hours = $73/month
Data Transfer: Included
Total: ~$73/month (fixed)
```

### AWS App Runner

**Pricing Model:**
- CPU: $0.064/vCPU-hour
- Memory: $0.007/GB-hour
- Requests: $0.0000000084 per request

**Monthly Cost Estimate:**
```
Compute (0.5 vCPU, 1GB, 24/7): 
  CPU: $0.064 × 0.5 × 730 = $23.36
  Memory: $0.007 × 1 × 730 = $5.11
  Requests: $0.0000000084 × 300,000 = $0.0025
Total: ~$28.47/month (with auto-scaling)
```

**With Scale-to-Zero (idle periods):**
```
Active time: 8 hours/day = 240 hours/month
  CPU: $0.064 × 0.5 × 240 = $7.68
  Memory: $0.007 × 1 × 240 = $1.68
  Requests: $0.0025
Total: ~$9.37/month (if scales to zero)
```

### GCP Cloud Run

**Pricing Model:**
- CPU: $0.00002400/vCPU-second
- Memory: $0.00000250/GB-second
- Requests: $0.40 per million requests
- Free tier: 2 million requests/month

**Monthly Cost Estimate:**
```
Compute (1 vCPU, 1GB, 2 sec/request):
  CPU: $0.00002400 × 1 × (300,000 × 2) = $14.40
  Memory: $0.00000250 × 1 × (300,000 × 2) = $1.50
  Requests: Free (under 2M)
Total: ~$15.90/month
```

**With Scale-to-Zero:**
- Only pay for actual request processing time
- Minimum billing: 100ms per request
- Estimated: ~$10-15/month (depends on traffic patterns)

### Low Volume Cost Comparison Summary

| Platform | Fixed Cost | Variable Cost | Total (10K req/day) | Best For |
|----------|------------|---------------|---------------------|-----------|
| **Akamai** | $73/month | $0 | ~$73/month | Predictable traffic |
| **AWS App Runner** | $0 | $9-28/month | ~$9-28/month | Variable traffic |
| **GCP Cloud Run** | $0 | $10-16/month | ~$10-16/month | Cost optimization |

---

### High Volume (1,000,000 requests/day) ⚠️

**For detailed high-volume cost analysis, see:** [`HIGH_VOLUME_COST_ANALYSIS.md`](HIGH_VOLUME_COST_ANALYSIS.md)

#### Quick Summary for 1M Requests/Day:

| Platform | Monthly Cost | Cost per Million Requests | Winner |
|----------|--------------|----------------------------|--------|
| **GCP Cloud Run** | **$42/month** | **$1.40** | ✅ Cheapest |
| **Akamai** | $146/month | $4.87 | Best for edge/latency |
| **AWS App Runner** | $720/month | $24.00 | Most expensive |

**Key Insights for High Volume:**
- **GCP Cloud Run** is **3.5x cheaper** than AWS at 1M requests/day
- **Akamai** becomes competitive due to fixed pricing model
- **Edge computing** (Akamai) provides significant latency benefits globally
- **Concurrency configuration** is critical for cost optimization

**See [`HIGH_VOLUME_COST_ANALYSIS.md`](HIGH_VOLUME_COST_ANALYSIS.md) for:**
- Detailed cost breakdowns
- Optimization strategies
- Scaling recommendations
- Geographic performance analysis

---

## 🌍 Edge Computing Analysis

### Geographic Distribution

#### Akamai Edge
- **Global Points of Presence:** 4,100+ locations
- **Edge Deployment:** Automatic via Akamai network
- **Latency Benefit:** 10-50ms reduction vs origin
- **Cache Strategy:** Not applicable (dynamic API)

#### AWS Edge
- **CloudFront:** 450+ edge locations
- **App Runner:** Regional deployment (choose region)
- **Latency Benefit:** Minimal (origin-based)
- **Edge Lambda:** Can add edge functions for preprocessing

#### GCP Edge
- **Cloud CDN:** 200+ edge locations
- **Cloud Run:** Regional deployment
- **Anthos Edge:** For true edge deployment
- **Latency Benefit:** Minimal (origin-based)

### Edge Strategy Comparison

| Feature | Akamai | AWS | GCP |
|---------|--------|-----|-----|
| **True Edge Compute** | ✅ Yes | ⚠️ Limited | ⚠️ Limited |
| **Global Distribution** | ✅ 4,100+ PoPs | ⚠️ Regional | ⚠️ Regional |
| **Edge Caching** | ✅ Yes | ✅ CloudFront | ✅ Cloud CDN |
| **Edge Functions** | ✅ EdgeWorkers | ✅ Lambda@Edge | ⚠️ Cloud Functions |
| **Low Latency** | ✅ Best | ⚠️ Good | ⚠️ Good |

### Recommendations

1. **For Global Low Latency:** Akamai (best edge network)
2. **For Cost Optimization:** GCP Cloud Run (pay per use)
3. **For AWS Ecosystem:** AWS App Runner (integration)
4. **For Edge + Cost:** Akamai at scale, GCP for small scale

---

## 📈 Monitoring & Metrics

### Key Metrics Dashboard

Create monitoring for:

1. **Performance:**
   - Response time (p50, p95, p99)
   - Error rate
   - Throughput (req/sec)

2. **Cost:**
   - Compute hours
   - Request count
   - Data transfer

3. **Availability:**
   - Uptime percentage
   - Health check status

### Monitoring Tools

- **Akamai:** Akamai Control Center, Real User Monitoring
- **AWS:** CloudWatch, X-Ray
- **GCP:** Cloud Monitoring, Cloud Trace

### Alerting

Set up alerts for:
- Response time > 5 seconds
- Error rate > 1%
- Cost threshold exceeded
- Service downtime

---

## 🎯 Conclusion & Recommendations

### Best Platform By Use Case

1. **Global Low Latency:** Akamai
2. **Cost Optimization:** GCP Cloud Run
3. **AWS Integration:** AWS App Runner
4. **Edge Computing:** Akamai (best network)

### Next Steps

1. Deploy to all three platforms
2. Run performance tests for 1 week
3. Compare costs and performance
4. Document findings
5. Choose platform based on priorities

---

## 📚 Additional Resources

- [Akamai Cloud Compute Docs](https://www.akamai.com/products/cloud-compute)
- [AWS App Runner Docs](https://docs.aws.amazon.com/apprunner/)
- [GCP Cloud Run Docs](https://cloud.google.com/run/docs)
- [FastAPI Deployment Guide](https://fastapi.tiangolo.com/deployment/)

