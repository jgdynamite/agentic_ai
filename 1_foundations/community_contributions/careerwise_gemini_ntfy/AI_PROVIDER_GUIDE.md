# AI Provider Configuration Guide

CareerWise now supports multiple AI providers! You can use Google Gemini (default), locally hosted models, or Akamai Inference Cloud.

## Quick Configuration

Set the `AI_PROVIDER` environment variable to switch between providers:
- `gemini` (default) - Google Gemini API
- `local` - Locally hosted models (Ollama, LM Studio, vLLM, etc.)
- `akamai` - Akamai Inference Cloud

---

## 🔵 Option 1: Google Gemini (Default)

**Best for:** Free tier, easy setup, good performance

### Setup

```bash
# In your .env.deploy or environment
AI_PROVIDER=gemini
GOOGLE_API_KEY=your-gemini-api-key-here
AI_MODEL=gemini-2.0-flash  # Optional, defaults to gemini-2.0-flash
```

### Get Your API Key
1. Go to https://makersuite.google.com/app/apikey
2. Create a new API key
3. Add it to your environment variables

---

## 🏠 Option 2: Locally Hosted Models

**Best for:** Privacy, no API costs, full control, offline use

### Supported Local Servers

The local provider works with any OpenAI-compatible API server:

#### Ollama (Recommended for Local)
```bash
# Install Ollama
# macOS/Linux: curl https://ollama.ai/install.sh | sh
# Windows: Download from https://ollama.ai

# Pull a model
ollama pull llama3.2
ollama pull mistral
ollama pull qwen2.5

# Start Ollama (runs on http://localhost:11434 by default)
ollama serve
```

#### LM Studio
1. Download from https://lmstudio.ai
2. Download a model (e.g., Llama 3.2, Mistral)
3. Start the local server (usually on `http://localhost:1234/v1`)

#### vLLM
```bash
# Install vLLM
pip install vllm

# Start server
python -m vllm.entrypoints.openai.api_server \
    --model meta-llama/Llama-3.2-3B-Instruct \
    --port 8000
```

### Configuration

```bash
# In your .env.deploy or environment
AI_PROVIDER=local
LOCAL_AI_BASE_URL=http://localhost:11434/v1  # Ollama default
AI_MODEL=llama3.2  # Model name you pulled/downloaded
LOCAL_AI_API_KEY=  # Optional, only if your server requires auth
```

### Example Configurations

**Ollama:**
```bash
AI_PROVIDER=local
LOCAL_AI_BASE_URL=http://localhost:11434/v1
AI_MODEL=llama3.2
```

**LM Studio:**
```bash
AI_PROVIDER=local
LOCAL_AI_BASE_URL=http://localhost:1234/v1
AI_MODEL=llama-3.2-3b-instruct-q4_K_M
```

**vLLM:**
```bash
AI_PROVIDER=local
LOCAL_AI_BASE_URL=http://localhost:8000/v1
AI_MODEL=meta-llama/Llama-3.2-3B-Instruct
```

### Notes on Local Models

- **Function Calling:** Some local models don't support function calling (tools). The code will automatically retry without tools if needed.
- **Performance:** Local models may be slower than cloud APIs, especially on CPU.
- **Memory:** Ensure you have enough RAM for the model (typically 4-16GB depending on model size).
- **Recommended Models:** 
  - `llama3.2` (3B) - Fast, good quality
  - `mistral` (7B) - Better quality, needs more RAM
  - `qwen2.5` (7B) - Great for chat

---

## 🌐 Option 3: Akamai Inference Cloud

**Best for:** Edge computing, low latency, global distribution

### Setup

1. **Get Akamai Account:**
   - Sign up at https://www.akamai.com
   - Access Akamai Inference Cloud

2. **Deploy Your Model:**
   - Upload or select your model in Akamai Control Center
   - Note the endpoint URL and model identifier

3. **Get API Credentials:**
   - Create API client in Akamai Control Center
   - Get API key/token

### Configuration

```bash
# In your .env.deploy or environment
AI_PROVIDER=akamai
AKAMAI_INFERENCE_API_KEY=your-akamai-api-key
AKAMAI_INFERENCE_BASE_URL=https://your-endpoint.akamai.com/v1
AI_MODEL=your-model-identifier
```

### Example

```bash
AI_PROVIDER=akamai
AKAMAI_INFERENCE_API_KEY=akab-xxxxx-xxxxx
AKAMAI_INFERENCE_BASE_URL=https://inference.akamai.com/v1
AI_MODEL=llama-3-70b
```

---

## 🔄 Switching Between Providers

You can easily switch providers by changing environment variables:

```bash
# Switch to local
export AI_PROVIDER=local
export LOCAL_AI_BASE_URL=http://localhost:11434/v1
export AI_MODEL=llama3.2

# Switch back to Gemini
export AI_PROVIDER=gemini
export GOOGLE_API_KEY=your-key

# Switch to Akamai
export AI_PROVIDER=akamai
export AKAMAI_INFERENCE_API_KEY=your-key
export AKAMAI_INFERENCE_BASE_URL=https://your-endpoint.com/v1
```

---

## 📝 Complete .env.deploy Example

```bash
# Application Configuration
NTFY_TOPIC=your-ntfy-topic-optional

# AI Provider Configuration
AI_PROVIDER=local  # Options: gemini, local, akamai
AI_MODEL=llama3.2

# For Gemini
GOOGLE_API_KEY=your-gemini-api-key-here

# For Local
LOCAL_AI_BASE_URL=http://localhost:11434/v1
LOCAL_AI_API_KEY=  # Optional

# For Akamai
AKAMAI_INFERENCE_API_KEY=your-akamai-api-key
AKAMAI_INFERENCE_BASE_URL=https://your-endpoint.akamai.com/v1

# Cloud Deployment (if deploying)
GCP_PROJECT_ID=your-gcp-project-id
AWS_ACCOUNT_ID=your-aws-account-id
# ... etc
```

---

## 🧪 Testing Your Configuration

1. **Start your local server** (if using local):
   ```bash
   ollama serve
   # or start LM Studio, vLLM, etc.
   ```

2. **Set environment variables:**
   ```bash
   export AI_PROVIDER=local
   export LOCAL_AI_BASE_URL=http://localhost:11434/v1
   export AI_MODEL=llama3.2
   ```

3. **Run the API:**
   ```bash
   python backend_api.py
   ```

4. **Test the endpoint:**
   ```bash
   curl -X POST http://localhost:8080/chat \
     -H "Content-Type: application/json" \
     -d '{"message": "Hello", "history": []}'
   ```

---

## 🐳 Docker Deployment

When deploying with Docker, make sure to:

1. **For Local Models:** Ensure your local server is accessible from the container, or run the model server in the same container/network.

2. **For Cloud Deployments:** 
   - Local models won't work on serverless platforms (Cloud Run, App Runner) unless you deploy the model server separately
   - Use Gemini or Akamai for serverless deployments
   - For local models, deploy to a VM or container service where you can run the model server

### Example Docker Compose (Local Model)

```yaml
version: '3.8'
services:
  ollama:
    image: ollama/ollama:latest
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
  
  careerwise:
    build: .
    ports:
      - "8080:8080"
    environment:
      - AI_PROVIDER=local
      - LOCAL_AI_BASE_URL=http://ollama:11434/v1
      - AI_MODEL=llama3.2
      - NTFY_TOPIC=your-topic
    depends_on:
      - ollama

volumes:
  ollama_data:
```

---

## ⚠️ Important Notes

1. **Function Calling Support:** 
   - Gemini: ✅ Full support
   - Local models: ⚠️ Varies by model (code auto-falls back)
   - Akamai: ✅ Depends on model

2. **Performance:**
   - Gemini: Fast, cloud-based
   - Local: Depends on hardware (GPU recommended)
   - Akamai: Fast, edge-optimized

3. **Costs:**
   - Gemini: Free tier available
   - Local: Free (hardware costs)
   - Akamai: Pay-per-use

4. **Privacy:**
   - Gemini: Data sent to Google
   - Local: 100% private, no data leaves your machine
   - Akamai: Depends on Akamai's privacy policy

---

## 🆘 Troubleshooting

### Local Model Not Responding
- Check if the server is running: `curl http://localhost:11434/v1/models`
- Verify the base URL is correct
- Check firewall settings

### Function Calling Errors
- Some models don't support tools - this is normal
- The code will automatically retry without tools
- Check logs for warnings

### Model Not Found
- For Ollama: Run `ollama pull <model-name>`
- For LM Studio: Download the model in the app
- Verify the model name matches exactly

---

## 📚 Additional Resources

- **Ollama:** https://ollama.ai
- **LM Studio:** https://lmstudio.ai
- **vLLM:** https://github.com/vllm-project/vllm
- **Akamai Inference:** https://www.akamai.com/solutions/cloud-computing/ai-inferencing
- **Google Gemini:** https://ai.google.dev
