import asyncio
import aiohttp
import json
import os
from dotenv import load_dotenv

load_dotenv()

async def make_request(session, prompt, request_id):
    url = "https://ca-a-e-devi-aigputrialopenwebui.wonderfulmeadow-3077b9fa.australiaeast.azurecontainerapps.io/ollama/api/generate"
    headers = {
        "Authorization": f"Bearer {os.getenv('OLLAMA_API_TOKEN')}",
        "Content-Type": "application/json"
    }
    data = {
        "model": "deepseek-r1:1.5b",
        "prompt": prompt,
        "stream": False
    }
    try:
        async with session.post(url, headers=headers, data=json.dumps(data)) as response:
            response.raise_for_status()  # Raise HTTPError for bad responses (4xx or 5xx)
            return await response.json()
    except aiohttp.ClientError as e:
        print(f"Request {request_id} failed: {e}")
        return None

async def main():
    prompts = [
        "Why are trees green?",
        "What stops the moon from hitting the earth?",
        "How do airplanes fly?",
        "Why do tyres with more tread wear faster?",
        "Is slowing time possible if the speed of light were achievable?",
        "What causes lightning in thunderstorms?",
        "How does a computer execute code?",
        "Why do cats purr?",
        "What is the impact of quantum mechanics on computing?",
        "How do galaxies form?"
    ]
    
    async with aiohttp.ClientSession() as session:
        tasks = [make_request(session, prompt, i) for i, prompt in enumerate(prompts)]
        results = await asyncio.gather(*tasks)

    for i, result in enumerate(results):
        if result:
            for key in list(result.keys()):
                if key.endswith('_duration'):
                    try:
                        result[key] = f"{round(float(result[key]) / 1e9, 2)}s"  # ns to seconds
                    except (ValueError, TypeError) as e:
                        print(f"Error converting duration for {key}: {e}")

            print(f"Request {i} successful. Duration: {result['total_duration']}")
        else:
            print(f"Request {i} failed.")

if __name__ == "__main__":
    asyncio.run(main())