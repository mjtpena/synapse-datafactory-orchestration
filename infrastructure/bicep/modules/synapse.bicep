// Synapse Workspace module
@description('Synapse workspace name')
param synapseWorkspaceName string

@description('Location for Synapse workspace')
param location string

@description('Storage account name for default storage')
param storageAccountName string

@description('File system name in storage account')
param fileSystemName string

@description('SQL Administrator login')
param sqlAdministratorLogin string

@description('Azure AD Object ID for Synapse Admin')
param synapseAdminObjectId string

@description('Environment name')
param environment string

@description('Log Analytics Workspace ID')
param logAnalyticsWorkspaceId string

@description('SQL Administrator password')
@secure()
param sqlAdministratorPassword string = newGuid()

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseWorkspaceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      accountUrl: 'https://${storageAccountName}.dfs.core.windows.net'
      filesystem: fileSystemName
    }
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorPassword
    publicNetworkAccess: 'Enabled'
    managedVirtualNetwork: 'default'
    managedResourceGroupName: '${synapseWorkspaceName}-managed-rg'
  }
  tags: {
    Environment: environment
    Purpose: 'DataAnalytics'
  }
}

// Grant Synapse workspace Storage Blob Data Contributor on the storage account
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(storageAccount.id, synapseWorkspace.id, 'StorageBlobDataContributor')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor
    principalId: synapseWorkspace.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Firewall rule to allow Azure services
resource firewallRule 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = {
  parent: synapseWorkspace
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Synapse SQL Pool (optional, commented out to save costs)
// resource sqlPool 'Microsoft.Synapse/workspaces/sqlPools@2021-06-01' = {
//   parent: synapseWorkspace
//   name: 'sqlpool01'
//   location: location
//   sku: {
//     name: 'DW100c'
//   }
//   properties: {
//     collation: 'SQL_Latin1_General_CP1_CI_AS'
//     createMode: 'Default'
//   }
// }

// Synapse Spark Pool
resource sparkPool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  parent: synapseWorkspace
  name: 'sparkpool01'
  location: location
  properties: {
    nodeCount: 3
    nodeSizeFamily: 'MemoryOptimized'
    nodeSize: 'Small'
    autoScale: {
      enabled: true
      minNodeCount: 3
      maxNodeCount: 10
    }
    autoPause: {
      enabled: true
      delayInMinutes: 15
    }
    sparkVersion: '3.4'
    dynamicExecutorAllocation: {
      enabled: true
      minExecutors: 1
      maxExecutors: 10
    }
  }
}

// Diagnostic settings for Synapse Workspace
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: synapseWorkspace
  name: '${synapseWorkspaceName}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'SynapseRbacOperations'
        enabled: true
      }
      {
        category: 'GatewayApiRequests'
        enabled: true
      }
      {
        category: 'SQLSecurityAuditEvents'
        enabled: true
      }
      {
        category: 'BuiltinSqlReqsEnded'
        enabled: true
      }
      {
        category: 'IntegrationPipelineRuns'
        enabled: true
      }
      {
        category: 'IntegrationActivityRuns'
        enabled: true
      }
      {
        category: 'IntegrationTriggerRuns'
        enabled: true
      }
    ]
  }
}

output workspaceName string = synapseWorkspace.name
output workspaceId string = synapseWorkspace.id
output workspaceIdentityPrincipalId string = synapseWorkspace.identity.principalId
output sparkPoolName string = sparkPool.name
