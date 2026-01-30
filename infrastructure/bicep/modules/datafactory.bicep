// Azure Data Factory module
@description('Data Factory name')
param dataFactoryName string

@description('Location for Data Factory')
param location string

@description('Environment name')
param environment string

@description('Log Analytics Workspace ID')
param logAnalyticsWorkspaceId string

@description('Enable Git integration')
param enableGitIntegration bool = false

@description('Git account name')
param gitAccountName string = ''

@description('Git repository name')
param gitRepositoryName string = ''

@description('Git collaboration branch')
param gitCollaborationBranch string = 'main'

@description('Git root folder')
param gitRootFolder string = '/'

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    repoConfiguration: enableGitIntegration ? {
      type: 'FactoryGitHubConfiguration'
      accountName: gitAccountName
      repositoryName: gitRepositoryName
      collaborationBranch: gitCollaborationBranch
      rootFolder: gitRootFolder
    } : null
  }
  tags: {
    Environment: environment
    Purpose: 'DataOrchestration'
  }
}

// Diagnostic settings for Data Factory
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: dataFactory
  name: '${dataFactoryName}-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'ActivityRuns'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'PipelineRuns'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'TriggerRuns'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'SSISPackageEventMessages'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'SSISPackageExecutableStatistics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'SSISPackageEventMessageContext'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'SSISPackageExecutionComponentPhases'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'SSISPackageExecutionDataStatistics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'SSISIntegrationRuntimeLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}

output dataFactoryName string = dataFactory.name
output dataFactoryId string = dataFactory.id
output dataFactoryIdentityPrincipalId string = dataFactory.identity.principalId
