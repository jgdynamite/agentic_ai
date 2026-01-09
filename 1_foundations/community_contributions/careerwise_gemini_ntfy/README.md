# 🤖 CareerWise Gemini Notify

**A Lightweight, API-Ready AI Chatbot for Personal Portfolios and Career Websites.**

| Technology       | Status                             |
| :--------------- | :--------------------------------- |
| **AI Model**     | Google Gemini (default), Local Models, or Akamai Inference |
| **Notifications**| ntfy (Open-Source, No API Key)     |
| **Architecture** | API-First (Python/FastAPI)        |
| **Deployment**   | Google Cloud Run, AWS, Akamai, or Local |

---

## 🚀 Why This Project?

This project is an ideal solution for developers or students looking to showcase **full-stack engineering skills** by building a practical, real-world AI microservice.

- **Add an AI-powered career assistant** to your personal website or portfolio.
- Show real engineering skills: **AI + Backend + Cloud + Frontend Integration**.
- Provide **instant, open-source notifications** using ntfy.
- Deploy a fully functional AI microservice **almost at zero cost**.

---

## ✨ Key Features

### 🧠 AI-Powered Guidance

Uses **flexible AI providers** to generate personalized and helpful career advice:
- **Google Gemini** (default) - Free tier available
- **Local Models** - Ollama, LM Studio, vLLM (100% private, no API costs)
- **Akamai Inference** - Edge-optimized AI inference

See [AI_PROVIDER_GUIDE.md](AI_PROVIDER_GUIDE.md) for setup instructions.

- Career answers
- Resume feedback
- Skill recommendations
- Interview guidance

### 🔔 ntfy Instant Notifications 

Push instant alerts for key events **without requiring any API keys or paid services**:

**Use Cases:**
- New advice generated
- System errors or missing info
- **Optional:** Employer interaction notification

**Works on:** 📱 Android · 🍏 iOS · 💻 Web · 🖥 Desktop

### ☁️ API-First Architecture

Stand-alone API for maximum flexibility:

- **Core:** Python
- **AI:** Gemini API
- **Web Framework:** Flask / FastAPI
- **Messaging:** ntfy for instant push notifications

### ⚡ Fast Portfolio Integration

Add the full chatbot widget to your site with **one HTML + JS snippet**.

---

## 🧪 Quick Start (Local Demo)

Get the API running locally in minutes!

### 1. Clone the Project

```bash
git clone https://github.com/ed-donner/agents.git
cd agents/1_foundations/community_contributions/careerwise_gemini_notify
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Configure AI Provider & ntfy

#### AI Provider
Choose your AI provider and set environment variables:

**Option 1: Google Gemini (default)**
```bash
export AI_PROVIDER=gemini
export GOOGLE_API_KEY=your-gemini-api-key
```

**Option 2: Local Model (Ollama)**
```bash
# Install Ollama: https://ollama.ai
ollama pull llama3.2
ollama serve

export AI_PROVIDER=local
export LOCAL_AI_BASE_URL=http://localhost:11434/v1
export AI_MODEL=llama3.2
```

**Option 3: Akamai Inference**
```bash
export AI_PROVIDER=akamai
export AKAMAI_INFERENCE_API_KEY=your-key
export AKAMAI_INFERENCE_BASE_URL=https://your-endpoint.com/v1
export AI_MODEL=your-model
```

See [AI_PROVIDER_GUIDE.md](AI_PROVIDER_GUIDE.md) for detailed instructions.

#### ntfy
- Open the ntfy app (Android/iOS/Web)
- Create a custom topic name (example: `my-career-alerts-123`)
- Add this topic name in:
  - `ntfy_integration.py`

### 4. Run the API Locally
```bash
python backend_api.py
```

### 📁 Folder Structure

The agent uses files inside the `me/` folder for personalized responses:

```
chatbot-project/
│
├── backend_api.py               # Main chatbot backend (API)
├── Dockerfile                   # Deploy to GCP Cloud Run or Docker
├── requirements.txt             # Dependencies
│
└── me/
    ├── resume_for_Virtual_Assistant.pdf   # Your resume for personalized context
    └── summary.txt                      # Short summary about you
```

---

## 🚀 Deploy to Google Cloud Run (Recommended)

Google Cloud Run is serverless, fast, and nearly free for lightweight projects.

**Step 1: Build Docker Image**

Replace `PROJECT_ID` with your real Google Cloud project ID.
```bash
gcloud builds submit --tag gcr.io/PROJECT_ID/chatbot-api
```

**Step 2: Deploy to Cloud Run**
```bash
gcloud run deploy chatbot-backend --image gcr.io/your_google_cloud_project_id/
chatbot-backend --platform managed --region asia-south1 --allow-unauthenticated --port 8080
--set-env-vars=GOOGLE_API_KEY=" type_your_api_key_here ",NTFY_TOPIC=" your_ntfy_topic"
```

Cloud Run will provide a public API endpoint:
```
https://chatbot-api-xxxxx.a.run.app
```

---

## 🌐 Integrate With Your Portfolio Website

Use the provided HTML + JavaScript widget—just paste into your portfolio, replacing:

- `your_api_end_point`

with your real Cloud Run URL (e.g., `https://chatbot-api-xxxxx.a.run.app`):

```js
fetch("https://chatbot-api-xxxxx.a.run.app", { ... });
```

📄 **Full HTML & CSS code:**  
[Click here](https://docs.google.com/document/d/1vTMalC9MHRaubbGgaU3mDGeWhz0Zha_2hAwq9tso9gw/edit?usp=sharing)


### Widget Features

- Floating chat icon
- Modern chat window
- Typing animations
- Chat history
- Direct API calls

---

## 📣 About ntfy Notifications

**ntfy:** Free, open-source push notification service.

| Feature      | Description                      |
| ------------ | ------------------------------- |
| Ease of Use  | No login or API key needed       |
| Flexibility  | Custom topics (ex: /alerts)      |
| Delivery     | Instant push notifications       |
| Control      | Option to self-host              |

**Setup:**
- Install ntfy
- Create a topic
- Add it to `ntfy_integration.py` in backend

---

## ⭐ Final Notes

This project makes an outstanding portfolio highlight by demonstrating:

- **AI Engineering:** Flexible AI provider integration (Gemini, Local Models, Akamai)
- **Backend + Frontend:** Full-stack skills
- **API Design:** Real-world architecture
- **Cloud Deployment:** Google Cloud Run
- **Unique Feature:** Push notifications via ntfy

Take your personal site to the next level—add a practical, modern AI microservice!
