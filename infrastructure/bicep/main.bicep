// Main Bicep template for Synapse Data Factory Orchestration
targetScope = 'resourceGroup'

@description('The location for all resources')
param location string = resourceGroup().location

@description('Environment name (dev, test, prod)')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

@description('Project name prefix')
param projectName string = 'synapse-df'

@description('Azure AD Object ID for Synapse Admin')
param synapseAdminObjectId string

@description('Azure AD Login for Synapse SQL Admin')
param synapseSqlAdminLogin string = 'sqladmin'

@description('Enable Synapse workspace')
param enableSynapse bool = true

@description('Enable Data Factory')
param enableDataFactory bool = true

// Variables
var uniqueSuffix = uniqueString(resourceGroup().id)
var storageAccountName = 'st${replace(projectName, '-', '')}${environment}${uniqueSuffix}'
var dataFactoryName = 'adf-${projectName}-${environment}-${uniqueSuffix}'
var synapseWorkspaceName = 'syn-${projectName}-${environment}-${uniqueSuffix}'
var keyVaultName = 'kv-${projectName}-${environment}-${substring(uniqueSuffix, 0, 6)}'
var logAnalyticsName = 'log-${projectName}-${environment}-${uniqueSuffix}'
var appInsightsName = 'appi-${projectName}-${environment}-${uniqueSuffix}'

// Storage Account for Data Lake
module storageAccount 'modules/storage.bicep' = {
  name: 'storageAccountDeployment'
  params: {
    storageAccountName: storageAccountName
    location: location
    environment: environment
  }
}

// Key Vault for secrets management
module keyVault 'modules/keyvault.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    keyVaultName: keyVaultName
    location: location
    environment: environment
  }
}

// Log Analytics Workspace
module logAnalytics 'modules/loganalytics.bicep' = {
  name: 'logAnalyticsDeployment'
  params: {
    logAnalyticsName: logAnalyticsName
    location: location
    environment: environment
  }
}

// Application Insights
module appInsights 'modules/appinsights.bicep' = {
  name: 'appInsightsDeployment'
  params: {
    appInsightsName: appInsightsName
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
    environment: environment
  }
}

// Azure Data Factory
module dataFactory 'modules/datafactory.bicep' = if (enableDataFactory) {
  name: 'dataFactoryDeployment'
  params: {
    dataFactoryName: dataFactoryName
    location: location
    environment: environment
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
  }
}

// Synapse Workspace
module synapseWorkspace 'modules/synapse.bicep' = if (enableSynapse) {
  name: 'synapseWorkspaceDeployment'
  params: {
    synapseWorkspaceName: synapseWorkspaceName
    location: location
    storageAccountName: storageAccount.outputs.storageAccountName
    fileSystemName: 'synapse'
    sqlAdministratorLogin: synapseSqlAdminLogin
    synapseAdminObjectId: synapseAdminObjectId
    environment: environment
    logAnalyticsWorkspaceId: logAnalytics.outputs.workspaceId
  }
}

// Outputs
output storageAccountName string = storageAccount.outputs.storageAccountName
output storageAccountId string = storageAccount.outputs.storageAccountId
output keyVaultName string = keyVault.outputs.keyVaultName
output keyVaultId string = keyVault.outputs.keyVaultId
output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId
output appInsightsId string = appInsights.outputs.appInsightsId
output dataFactoryName string = enableDataFactory ? dataFactory.outputs.dataFactoryName : ''
output dataFactoryId string = enableDataFactory ? dataFactory.outputs.dataFactoryId : ''
output synapseWorkspaceName string = enableSynapse ? synapseWorkspace.outputs.workspaceName : ''
output synapseWorkspaceId string = enableSynapse ? synapseWorkspace.outputs.workspaceId : ''
