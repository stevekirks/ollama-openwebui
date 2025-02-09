# Test Results

## Testing requests to Ollama in a Azure Container App on the T4 (AUD$14/day) infrastructure

### Summary of Observations
Single requests on model 14B and below are responsive. It's noticably slower with larger models and with concurrent requests, to the point that its not usable.

### Results
Using random simple prompts such as "Why is the sky blue?", "What causes lightning in thunderstorms?", etc.

**Deepseek-r1:1.5B**  
Request 0: Duration: 4.39s  
Request 1: Duration: 6.67s  
Request 2: Duration: 5.79s  
Request 3: Duration: 21.13s  
Request 4: Duration: 31.91s  
Request 5: Duration: 1.98s  
Request 6: Duration: 28.43s  
Request 7: Duration: 2.43s  
Request 8: Duration: 33.76s  
Request 9: Duration: 28.81s  

**Deepseek-r1:8B**  
Request 0: Duration: 69.36s  
Request 1: Duration: 32.91s  
Request 2: Duration: 87.48s  
Request 3: Duration: 137.84s  
Request 4: Duration: 66.76s  
Request 5: Duration: 116.25s  
Request 6: Duration: 63.9s  
Request 7: Duration: 119.9s  
Request 8: Duration: 136.61s  
Request 9: Duration: 75.79s  

**Deepseek-r1:14b**  
Request 0: Duration: 150.96s  
Request 1: Duration: 104.0s  
Request 2: Duration: 40.11s  
Request 3: Duration: 192.14s  
Request 4 failed.  
Request 5: Duration: 116.46s  
Request 6 failed.  
Request 7: Duration: 155.13s  
Request 8 failed.  
Request 9: Duration: 69.91s  

**phi4**  
Request 0: Duration: 73.01s  
Request 1: Duration: 21.0s  
Request 2: Duration: 43.78s  
Request 3: Duration: 26.84s  
Request 4: Duration: 35.99s  
Request 5: Duration: 57.49s  
Request 6: Duration: 108.32s  
Request 7: Duration: 93.28s  
Request 8: Duration: 83.1s  
Request 9: Duration: 80.65s  