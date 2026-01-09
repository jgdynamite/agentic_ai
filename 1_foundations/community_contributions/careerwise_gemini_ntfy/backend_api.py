import os
import json
from dotenv import load_dotenv
from openai import OpenAI
from pypdf import PdfReader
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import asyncio
import requests
from abc import ABC, abstractmethod
from typing import List, Dict, Any, Optional

load_dotenv(override=True)

def push(text):
    """
    Sends a push notification using ntfy.sh.
    The NTFY_TOPIC environment variable must be set.
    """
    topic = os.getenv("NTFY_TOPIC")
    if topic:
        url = f"https://ntfy.sh/{topic}"
        requests.post(url, data=text.encode("utf-8"))
    else:
        print("NTFY_TOPIC environment variable not set. Push notification not sent.")

def record_user_details(email, name="Name not provided", notes="not provided"):
    push(f"Recording {name} with email {email} and notes {notes}")
    return {"recorded": "ok"}

def record_unknown_question(question):
    push(f"Recording {question}")
    return {"recorded": "ok"}

record_user_details_json = {
    "name": "record_user_details",
    "description": "Use this tool to record that a user is interested in being in touch and provided an email address",
    "parameters": {
        "type": "object",
        "properties": {
            "email": {
                "type": "string",
                "description": "The email address of this user"
            },
            "name": {
                "type": "string",
                "description": "The user's name, if they provided it"
            },
            "notes": {
                "type": "string",
                "description": "Any additional information about the conversation that's worth recording to give context"
            }
        },
        "required": ["email"],
        "additionalProperties": False
    }
}

record_unknown_question_json = {
    "name": "record_unknown_question",
    "description": "Always use this tool to record any question that couldn't be answered as you didn't know the answer",
    "parameters": {
        "type": "object",
        "properties": {
            "question": {
                "type": "string",
                "description": "The question that couldn't be answered"
            },
        },
        "required": ["question"],
        "additionalProperties": False
    }
}

tools = [{"type": "function", "function": record_user_details_json},
         {"type": "function", "function": record_unknown_question_json}]


# ============================================================================
# AI Provider Abstraction Layer
# ============================================================================

class AIProvider(ABC):
    """Abstract base class for AI providers"""
    
    @abstractmethod
    async def chat_completion(self, messages: List[Dict[str, Any]], tools: List[Dict]) -> Any:
        """Generate a chat completion response"""
        pass


class GeminiProvider(AIProvider):
    """Google Gemini provider (default)"""
    
    def __init__(self, api_key: str, model: str = "gemini-2.0-flash"):
        self.client = OpenAI(
            api_key=api_key,
            base_url="https://generativelanguage.googleapis.com/v1beta/openai/"
        )
        self.model = model
    
    async def chat_completion(self, messages: List[Dict[str, Any]], tools: List[Dict]) -> Any:
        return await asyncio.to_thread(
            lambda: self.client.chat.completions.create(
                model=self.model,
                messages=messages,
                tools=tools
            )
        )


class LocalProvider(AIProvider):
    """Locally hosted model provider (Ollama, LM Studio, vLLM, etc.)"""
    
    def __init__(self, base_url: str, model: str, api_key: Optional[str] = None):
        """
        Args:
            base_url: Local API endpoint (e.g., "http://localhost:11434/v1" for Ollama)
            model: Model name (e.g., "llama3.2", "mistral", "qwen2.5")
            api_key: Optional API key if your local server requires authentication
        """
        self.client = OpenAI(
            api_key=api_key or "not-needed",
            base_url=base_url
        )
        self.model = model
    
    async def chat_completion(self, messages: List[Dict[str, Any]], tools: List[Dict]) -> Any:
        # Note: Some local models may not support tools/function calling
        # If tools are not supported, remove them from the request
        try:
            return await asyncio.to_thread(
                lambda: self.client.chat.completions.create(
                    model=self.model,
                    messages=messages,
                    tools=tools if tools else None
                )
            )
        except Exception as e:
            # Fallback: try without tools if the model doesn't support them
            if "tools" in str(e).lower() or "function" in str(e).lower():
                print(f"Warning: Model doesn't support tools, retrying without tools", flush=True)
                return await asyncio.to_thread(
                    lambda: self.client.chat.completions.create(
                        model=self.model,
                        messages=messages
                    )
                )
            raise


class AkamaiInferenceProvider(AIProvider):
    """Akamai Inference Cloud provider"""
    
    def __init__(self, api_key: str, base_url: str, model: str):
        """
        Args:
            api_key: Akamai API key/token
            base_url: Akamai Inference endpoint URL
            model: Model identifier on Akamai
        """
        self.client = OpenAI(
            api_key=api_key,
            base_url=base_url
        )
        self.model = model
    
    async def chat_completion(self, messages: List[Dict[str, Any]], tools: List[Dict]) -> Any:
        return await asyncio.to_thread(
            lambda: self.client.chat.completions.create(
                model=self.model,
                messages=messages,
                tools=tools
            )
        )


def create_ai_provider() -> AIProvider:
    """
    Factory function to create the appropriate AI provider based on environment variables.
    
    Environment Variables:
        AI_PROVIDER: "gemini" (default), "local", or "akamai"
        
    For Gemini:
        GOOGLE_API_KEY: Your Gemini API key
        AI_MODEL: Model name (default: "gemini-2.0-flash")
        
    For Local:
        LOCAL_AI_BASE_URL: Base URL (e.g., "http://localhost:11434/v1" for Ollama)
        AI_MODEL: Model name (e.g., "llama3.2", "mistral")
        LOCAL_AI_API_KEY: Optional API key
        
    For Akamai:
        AKAMAI_INFERENCE_API_KEY: Akamai API key
        AKAMAI_INFERENCE_BASE_URL: Akamai endpoint URL
        AI_MODEL: Model identifier on Akamai
    """
    provider_type = os.getenv("AI_PROVIDER", "gemini").lower()
    model = os.getenv("AI_MODEL", "gemini-2.0-flash")
    
    if provider_type == "local":
        base_url = os.getenv("LOCAL_AI_BASE_URL", "http://localhost:11434/v1")
        api_key = os.getenv("LOCAL_AI_API_KEY")
        if not base_url:
            raise ValueError("LOCAL_AI_BASE_URL environment variable is required for local provider")
        print(f"Using Local AI Provider: {base_url} with model {model}", flush=True)
        return LocalProvider(base_url=base_url, model=model, api_key=api_key)
    
    elif provider_type == "akamai":
        api_key = os.getenv("AKAMAI_INFERENCE_API_KEY")
        base_url = os.getenv("AKAMAI_INFERENCE_BASE_URL")
        if not api_key or not base_url:
            raise ValueError("AKAMAI_INFERENCE_API_KEY and AKAMAI_INFERENCE_BASE_URL are required for Akamai provider")
        print(f"Using Akamai Inference Provider: {base_url} with model {model}", flush=True)
        return AkamaiInferenceProvider(api_key=api_key, base_url=base_url, model=model)
    
    else:  # Default to Gemini
        api_key = os.getenv("GOOGLE_API_KEY")
        if not api_key:
            raise ValueError("GOOGLE_API_KEY environment variable is required for Gemini provider")
        print(f"Using Gemini Provider with model {model}", flush=True)
        return GeminiProvider(api_key=api_key, model=model)


class Me:

    def __init__(self):
        load_dotenv(override=True)
        # Use the factory to create the appropriate AI provider
        self.ai_provider = create_ai_provider()
        self.name = "Mahesh Dindur"
        reader = PdfReader("me/resume_for_Virtual_Assistant.pdf")
        self.linkedin = ""
        for page in reader.pages:
            text = page.extract_text()
            if text:
                self.linkedin += text
        # Try summary.txt first, then summary (for backward compatibility)
        summary_path = "me/summary.txt" if os.path.exists("me/summary.txt") else "me/summary"
        with open(summary_path, "r", encoding="utf-8") as f:
            self.summary = f.read()

    def handle_tool_call(self, tool_calls):
        results = []
        for tool_call in tool_calls:
            tool_name = tool_call.function.name
            arguments = json.loads(tool_call.function.arguments)
            print(f"Tool called: {tool_name}", flush=True)
            tool = globals().get(tool_name)
            result = tool(**arguments) if tool else {}
            results.append({"role": "tool", "content": json.dumps(result), "tool_call_id": tool_call.id})
        return results

    def system_prompt(self):
        system_prompt = f"You are acting as {self.name}. You are answering questions on {self.name}'s website, " \
                        f"particularly questions related to {self.name}'s career, background, skills and experience. " \
                        f"Your responsibility is to represent {self.name} for interactions on the website as faithfully as possible. " \
                        f"You are given a summary of {self.name}'s background and LinkedIn profile which you can use to answer questions. " \
                        f"Be professional and engaging, as if talking to a potential client or future employer who came across the website. " \
                        f"If you don't know the answer to any question, use your record_unknown_question tool to record the question that you couldn't answer, even if it's about something trivial or unrelated to career. " \
                        f"If the user is engaging in discussion, try to steer them towards getting in touch via email; ask for their email and record it using your record_user_details tool. "

        system_prompt += f"\n\n## Summary:\n{self.summary}\n\n## LinkedIn Profile:\n{self.linkedin}\n\n"
        system_prompt += f"With this context, please chat with the user, always staying in character as {self.name}."
        return system_prompt

    async def chat(self, message, history):
        messages = [{"role": "system", "content": self.system_prompt()}] + history + [{"role": "user", "content": message}]
        done = False
        max_iterations = 10  # Prevent infinite loops
        iteration = 0
        
        while not done and iteration < max_iterations:
            iteration += 1
            response = await self.ai_provider.chat_completion(messages, tools)
            
            # Handle tool calls if supported
            if hasattr(response.choices[0], 'finish_reason') and response.choices[0].finish_reason == "tool_calls":
                if hasattr(response.choices[0].message, 'tool_calls') and response.choices[0].message.tool_calls:
                    message_obj = response.choices[0].message
                    tool_calls = message_obj.tool_calls
                    results = self.handle_tool_call(tool_calls)
                    messages.append(message_obj)
                    messages.extend(results)
                else:
                    done = True
            else:
                done = True
        
        return response.choices[0].message.content


app = FastAPI()
me = Me()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust this to your website domain in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    message: str
    history: list = []

@app.post("/chat")
async def chat_endpoint(request: ChatRequest):
    try:
        response_text = await me.chat(request.message, request.history)
        return {"response": response_text}
    except Exception as e:
        # Log the error for debugging
        error_message = str(e)
        print(f"Error in chat endpoint: {error_message}", flush=True)
        
        # Return a user-friendly error message with proper CORS headers
        from fastapi.responses import JSONResponse
        return JSONResponse(
            status_code=500,
            content={
                "error": "I'm sorry, I encountered an error processing your request.",
                "details": error_message if "429" in error_message or "quota" in error_message.lower() else None
            }
        )