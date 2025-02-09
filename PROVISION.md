### Provision Azure Resources

This command creates the Azure container apps and persistant storage for ollama models.
Note that it doesnt setup persistance storage for OpenWebUI (see issues in readme).
```
az deployment group create --subscription ?? --resource-group ?? --template-file template.bicep --parameters resourceLabel='mysandbox'
```