# Test Results

Ollama v0.5.7

## Summary of Observations using T4 or A100 infrastructure
The first request after switching a model is slow (assuming it's loading the model into memory). Subsequent requests are much faster.
With just a single GPU, it doesn't handle concurrency well.
For Deepseek-r1, both infrastructure can run the 14B parameter model. Neither can adequately run the 32B model with concurrent requests.

## Testing requests to Ollama in a Azure Container App on the T4 GPU (AUD$14/day (when continuously running)) infrastructure

### Summary of Observations
Single requests on model 14B and below are responsive. It's noticably slower with larger models and with concurrent requests, to the point that its not usable.

### Results
Using random simple prompts such as "Why is the sky blue?", "What causes lightning in thunderstorms?", etc.
Duration, in seconds, is with the response completed.

**Deepseek-r1:1.5B**  
| Request | Duration |
|---------|---------:|
| 0       | 4.39s    |
| 1       | 6.67s    |
| 2       | 5.79s    |
| 3       | 21.13s   |
| 4       | 31.91s   |
| 5       | 1.98s    |
| 6       | 28.43s   |
| 7       | 2.43s    |
| 8       | 33.76s   |
| 9       | 28.81s   |

**Deepseek-r1:8B**  
| Request | Duration   |
|---------|-----------:|
| 0       | 69.36s     |
| 1       | 32.91s     |
| 2       | 87.48s     |
| 3       | 137.84s    |
| 4       | 66.76s     |
| 5       | 116.25s    |
| 6       | 63.9s      |
| 7       | 119.9s     |
| 8       | 136.61s    |
| 9       | 75.79s     | 

**Deepseek-r1:14b**  
| Request | Duration   |
|---------|-----------:|
| 0       | 150.96s    |
| 1       | 104.0s     |
| 2       | 40.11s     |
| 3       | 192.14s    |
| 4       | failed     |
| 5       | 116.46s    |
| 6       | failed     |
| 7       | 155.13s    |
| 8       | failed     |
| 9       | 69.91s     |

**Deepseek-r1:32b**  
All timed out.

**phi4**  
| Request | Duration |
|---------|---------:|
| 0       | 73.01s   |
| 1       | 21.0s    |
| 2       | 43.78s   |
| 3       | 26.84s   |
| 4       | 35.99s   |
| 5       | 57.49s   |
| 6       | 108.32s  |
| 7       | 93.28s   |
| 8       | 83.1s    |
| 9       | 80.65s   |


## Testing requests to Ollama in a Azure Container App on the A100 GPU (AUD$106/day (when continuously running)) infrastructure

### Summary of Observations


### Results
Using random simple prompts such as "Why is the sky blue?", "What causes lightning in thunderstorms?", etc.

**Deepseek-r1:1.5B**  
| Request | Duration |
|---------|---------:|
| 0       | 1.83s    |
| 1       | 17.71s   |
| 2       | 15.9s    |
| 3       | 9.91s    |
| 4       | 15.61s   |
| 5       | 14.99s   |
| 6       | 13.82s   |
| 7       | 0.54s    |
| 8       | 19.52s   |
| 9       | 11.34s   |

**Deepseek-r1:8B**  
| Request | Duration |
|---------|---------:|
| 0       | 18.16s   |
| 1       | 19.36s   |
| 2       | 6.85s    |
| 3       | 38.92s   |
| 4       | 37.44s   |
| 5       | 30.19s   |
| 6       | 16.14s   |
| 7       | 9.17s    |
| 8       | 26.76s   |
| 9       | 27.88s   |

**Deepseek-r1:14b**  
| Request | Duration |
|---------|---------:|
| 0       | 39.27s   |
| 1       | 30.96s   |
| 2       | 50.21s   |
| 3       | 73.68s   |
| 4       | 27.61s   |
| 5       | 31.68s   |
| 6       | 82.8s    |
| 7       | 37.22s   |
| 8       | 75.07s   |
| 9       | 54.22s   |

**Deepseek-r1:32b**  
All timed out.

**phi4**  
| Request | Duration |
|---------|---------:|
| 0       | 9.01s    |
| 1       | 9.49s    |
| 2       | 12.27s   |
| 3       | 25.74s   |
| 4       | 6.7s     |
| 5       | 17.11s   |
| 6       | 20.43s   |
| 7       | 19.28s   |
| 8       | 21.02s   |
| 9       | 27.84s   |