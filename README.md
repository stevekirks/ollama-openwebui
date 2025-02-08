# Open Web UI and Ollama

We're using OpenWebUI as a way to secure the Ollama API and its providing a convenient front-end.

## Running Locally (Windows)

### Run Docker container
Create 2 folders where WebUI and Ollama will persist data. Then in the following command, update the folders and run:
```powershell
docker run -d -p 3083:8080 --gpus=all -v C:\dev\ollama\container_storage_ollama:/root/.ollama -v C:\dev\ollama\container_storage_open_webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:ollama
```

Then navigate to http://localhost:3083

## Steps to setup Ollama securely in an Azure Web App

### Create Azure Web App for Container.
Use docker image:  
Server: **https://ghcr.io**  
Name: **open-webui/open-webui:ollama**

### Create Azure Storage
Create two file shares, one for **webui** and one for **ollama**.

### Configure Web App
Go to Environment Variables and add variable `WEBSITES_PORT` with value `8080`. This maps requests to the port that OpenWebUI is listening on.

Go the Configuration > Path mappings and add the two file shares. Mount Paths:
-   `/app/backend/data` to the webui share.
-   `/root` to the ollama share. Note that the mount should be to `/root/.ollama` but Azure Web Apps don't support the dot special character :(


## Config within OpenUI

### Download models
Under Admin Panel > Settings > Models, click Manage Models, then Pull a model.

### Get the API Key
Under User Settings > Account

## Make a Request
Using the generate endpoint:
```powershell
curl -X POST https://sollama.azurewebsites.net/ollama/api/generate -H "Authorization: Bearer your_api_key" -H "Content-Type: application/json" -d '{"model": "phi3:latest", "prompt": "Why is the sky blue?","stream": false}'
```
Using the chat endpoint:
```powershell
curl -X POST https://sollama.azurewebsites.net/ollama/api/chat -H "Authorization: Bearer your_api_key" -H "Content-Type: application/json" -d '{"model": "deepseek-r1:1.5b","messages": [{"role": "user","content": "Why is the sky blue?"}]}'
```

## Azure Web App Inference Processing Performance:
No GPU's, so the model performance is pretty bad.  

Running on Premium v3 P1mv3 (2 vCPU, 16 GB mem, AU$175/mth).  
Prompt: Why is the sky blue?  
Deepseek-r1:1.5B response time: 36s  
Phi3:3.8B response time: 2m12s  
Deepseek-r1:8B response time: 4m3s  



## Steps to setup Ollama securely in an Azure Container App

At the time of writing there is [GPU support in preview in AusEast](https://learn.microsoft.com/en-us/azure/container-apps/gpu-serverless-overview#supported-regions).

Run the bicep template to provision. **Warning: currently untested.**

### Old way to be replaced...

### Create Resources
-   Specified the workload to use the T4 GPU.
-   Created Storage Account with two file shares and mounted them similar to above, except Container apps support "dots" in mount paths so used the intended `/root/.ollama`.

### Issues & Performance

Could not get Open WebUI to load. I set the Target Port to 8080 and kept getting this error:
> The TargetPort 8080 does not match the listening port 11434

11434 is the Ollama port, so it should only be used internally. 8080 is the Open WebUI port.
I also tried changing the Open WebUI port to 80 using env var `PORT` but it still complained.

Just to temporarily try the GPU, I switched to running the standalone Ollama container (docker hub, **ollama/ollama:latest**), without Open WebUI and its security.

Pull the models via the API:
```powershell
curl -X POST https://aigputest.blackbay-fb02aab2.australiaeast.azurecontainerapps.io/api/pull -d '{"model":"phi4"}'
```
And make chat requests similar to above.

Was able to get results from this. Still not good, but better than the no-GPU App Service as could use models with more parameters.

Prompt: Why is the sky blue?  
Deepseek-r1:1.5B response time: 1.1s  
Deepseek-r1:8B response time: 1m45s  
Phi4 response time: 3m55s  