# Open Web UI and Ollama

We're using OpenWebUI as a way to secure the Ollama API and its providing a convenient front-end.

## Running Locally (Windows)

### Run Docker container
Create 2 folders where WebUI and Ollama will persist data. Then in the following command, update the folders and run:
```powershell
docker run -d -p 3083:8080 --gpus=all -v C:\dev\ollama\container_storage_ollama:/root/.ollama -v C:\dev\ollama\container_storage_open_webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:ollama
```

Then navigate to http://localhost:3083


## Steps to setup Ollama in an Azure Container App

At the time of writing there is [GPU support in preview in AusEast](https://learn.microsoft.com/en-us/azure/container-apps/gpu-serverless-overview#supported-regions).

Run the bicep template to provision the Azure resources. This will setup everything except for persistant storage for OpenWebUI - keep reading Issues for why.

### Issues

#### Storage for OpenWebUI issue
OpenWebUI uses SQLite by default. A volume uses an Azure File Share and the Container App talks to it using the SMB protocol, which doesn't work well with SQLite. The error I got was:
> peewee.OperationalError: database is locked

##### Resolution:
I was able to get persistant storage for Open WebUI by using a PostgreSQL DB instead of the default Sqlite DB. So instead of setting up a volume in the OpenWebUI container I created an Azure Database for Postgres Flexible Server, created an admin account, then, set the environment variable `DATABASE_URL` in the OpenWebUI container app to: 
`postgres://username:password@your-postgres-server.postgres.database.azure.com:5432/postgres`

#### OpenWebUI+Ollama bundle issue
If you're wondering why there are 2 containers, one for Ollama and one for OpenWebUI, instead of a single bundled container, it's because I 
could not get OpenWebUI+Ollama bundle container to load in an Azure Container app. I set the Target Port to 8080 and kept getting this error:
> The TargetPort 8080 does not match the listening port 11434

11434 is the Ollama port, so it should only be used internally. 8080 is the Open WebUI port.
I also tried changing the Open WebUI port to 80 using env var `PORT` but it still complained.


### Config within OpenUI

#### Download models
Under Admin Panel > Settings > Models, click Manage Models, then Pull a model.

#### Get the API Key
Under User Settings > Account

### Make a Request
Using the generate endpoint:
```powershell
curl -X POST https://sollama.azurewebsites.net/ollama/api/generate -H "Authorization: Bearer your_api_key" -H "Content-Type: application/json" -d '{"model": "phi3:latest", "prompt": "Why is the sky blue?","stream": false}'
```
Using the chat endpoint:
```powershell
curl -X POST https://sollama.azurewebsites.net/ollama/api/chat -H "Authorization: Bearer your_api_key" -H "Content-Type: application/json" -d '{"model": "deepseek-r1:1.5b","messages": [{"role": "user","content": "Why is the sky blue?"}]}'
```

### Performance

It seems to take a while to respond on initial prompt (it doesnt seem to be fast at model switching), but afterwards is fairly responsive.

#### Some times with the T4 GPU
Prompt: Why is the sky blue?  
Deepseek-r1:1.5B response time: 1s  
Deepseek-r1:8B response time: 25s  
Phi4 response time: 17s  

Prompt: Write python to extract text from HTML content and save images locally.
Deepseek-r1:1.5B response time: 8s  
Deepseek-r1:8B response time: 46s  
Phi4 response time: 44s  

## Steps to setup Ollama securely in an Azure Web App (not recommended)

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

### Azure Web App Inference Processing Performance:
No GPU's, so the model performance is pretty bad.  

Running on Premium v3 P1mv3 (2 vCPU, 16 GB mem, AU$175/mth).  
Prompt: Why is the sky blue?  
Deepseek-r1:1.5B response time: 36s  
Phi3:3.8B response time: 2m12s  
Deepseek-r1:8B response time: 4m3s  
