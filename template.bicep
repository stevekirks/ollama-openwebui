/*
Create Ollama and Open Web UI container apps, with persistant storage for ollama models, in a managed environment with a GPU workload profile.
Note that Ollama and Open Web UI are seperate because of an error loading the bundled container.
The Ollama container port is exposed within the container environment for the Open WebUI container to call.
*/
param envResourceName string = 'env-a-e-devi-aigputrial'
param ollamaContainerAppName string = 'ca-a-e-devi-aigputrialollama'
param storageAccountName string = 'staedeviaigputrial'
param openWebUiContainerAppName string = 'ca-a-e-devi-aigputrialopenwebui'
param logWorkspaceName string = 'logwspc-a-e-devi-aigputrial'

var ollamaWorkloadProfileT4 = 'gpu-t4'
var ollamaContainerResourcesT4 = {
  cpu: 8
  memory: '56Gi'
}
var ollamaWorkloadProfileA100 = 'gpu-nc24a100'
var ollamaContainerResourcesA100 = {
  cpu: 24
  memory: '220Gi'
}

resource envResource 'Microsoft.App/managedEnvironments@2024-08-02-preview' = {
  name: envResourceName
  location: 'Australia East'
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logWorkspace.properties.customerId
        sharedKey: logWorkspace.listKeys().primarySharedKey
      }
    }
    zoneRedundant: false
    kedaConfiguration: {}
    daprConfiguration: {}
    customDomainConfiguration: {}
    workloadProfiles: [
      {
        workloadProfileType: 'Consumption'
        name: 'Consumption'
        enableFips: false
      }
      {
        workloadProfileType: 'Consumption-GPU-NC24-A100'
        name: ollamaWorkloadProfileA100
        enableFips: false
      }
      {
        workloadProfileType: 'Consumption-GPU-NC8as-T4'
        name: ollamaWorkloadProfileT4
        enableFips: false
      }
    ]
    peerAuthentication: {
      mtls: {
        enabled: false
      }
    }
    peerTrafficConfiguration: {
      encryption: {
        enabled: false
      }
    }
    publicNetworkAccess: 'Enabled'
  }
}

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logWorkspaceName
  location: 'australiaeast'
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      legacy: 0
      searchVersion: 1
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: 'australiaeast'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    largeFileSharesState: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource ollamaContainerApp 'Microsoft.App/containerapps@2024-08-02-preview' = {
  name: ollamaContainerAppName
  location: 'Australia East'
  kind: 'containerapps'
  identity: {
    type: 'None'
  }
  properties: {
    managedEnvironmentId: envResource.id
    environmentId: envResource.id
    workloadProfileName: ollamaWorkloadProfileT4
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: false
        targetPort: 11434
        exposedPort: 0
        transport: 'Auto'
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: false
        clientCertificateMode: 'Ignore'
        stickySessions: {
          affinity: 'none'
        }
      }
      identitySettings: []
      maxInactiveRevisions: 100
    }
    template: {
      containers: [
        {
          image: 'docker.io/ollama/ollama:latest'
          imageType: 'ContainerImage'
          name: ollamaContainerAppName
          resources: ollamaContainerResourcesT4
          probes: []
          volumeMounts: [
            {
              volumeName: 'ollama-vol'
              mountPath: '/root/.ollama'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
        cooldownPeriod: 300
        pollingInterval: 30
        rules: [
          {
            name: 'http-scaler'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
      volumes: [
        {
          name: 'ollama-vol'
          storageType: 'AzureFile'
          storageName: ollamaEnvStorage.name
        }
      ]
    }
  }
}

resource openWebUiContainerApp 'Microsoft.App/containerapps@2024-08-02-preview' = {
  name: openWebUiContainerAppName
  location: 'Australia East'
  kind: 'containerapps'
  identity: {
    type: 'None'
  }
  properties: {
    managedEnvironmentId: envResource.id
    environmentId: envResource.id
    workloadProfileName: 'Consumption'
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 8080
        exposedPort: 0
        transport: 'Auto'
        traffic: [
          {
            revisionName: '${openWebUiContainerAppName}--iselc2b'
            weight: 100
          }
        ]
        allowInsecure: false
        stickySessions: {
          affinity: 'none'
        }
      }
      identitySettings: []
      maxInactiveRevisions: 100
    }
    template: {
      containers: [
        {
          image: 'ghcr.io/open-webui/open-webui:main'
          imageType: 'ContainerImage'
          name: openWebUiContainerAppName
          env: [
            {
              name: 'OLLAMA_BASE_URL'
              value: 'https://${ollamaContainerApp.properties.configuration.ingress.fqdn}'
            }
          ]
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          probes: []
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
        cooldownPeriod: 300
        pollingInterval: 30
      }
      volumes: []
    }
  }
}

resource ollamaEnvStorage 'Microsoft.App/managedEnvironments/storages@2024-08-02-preview' = {
  parent: envResource
  name: 'ollama-env-storage'
  properties: {
    azureFile: {
      accountName: storageAccount.name
      accountKey: storageAccount.listKeys().keys[0].value
      shareName: ollamaStorageAccountFileShare.name
      accessMode: 'ReadWrite'
    }
  }
}

resource defaultStorageAccountFileService 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: false
    }
  }
}

resource ollamaStorageAccountFileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = {
  parent: defaultStorageAccountFileService
  name: 'ollama-fs'
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 1024
    enabledProtocols: 'SMB'
  }
}
