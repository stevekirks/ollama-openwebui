# Open Web UI and Ollama

We're using OpenWebUI as a way to secure the Ollama API and its providing a convenient front-end.

## Running Locally
Is easy
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

### Make a request
Using the generate endpoint:
```powershell
curl -X POST https://sollama.azurewebsites.net/ollama/api/generate -H "Authorization: Bearer your_api_key" -H "Content-Type: application/json" -d '{"model": "phi3:latest", "prompt": "Why is the sky blue?","stream": false}'
```
Using the chat endpoint:
```powershell
curl -X POST https://sollama.azurewebsites.net/ollama/api/chat -H "Authorization: Bearer your_api_key" -H "Content-Type: application/json" -d '{"model": "deepseek-r1:1.5b","messages": [{"role": "user","content": "Why is the sky blue?"}]}'
```

## Azure Web App Performance:
Model performance isn't very good for the price.

Running on Premium v3 P1mv3 (2 vCPU, 16 GB mem, AU$175/mth).
Prompt: Why is the sky blue?
Deepseek-r1:8B response time: 36s
Phi3:3.8B response time: 2m12s
Deepseek-r1:1.5B response time: 4m3s