# Synapse Data Factory Orchestration

A comprehensive Azure Data Factory and Synapse Analytics orchestration project featuring ETL pipelines, infrastructure as code, monitoring, and best practices for enterprise data integration.

## Overview

This repository provides a complete solution for data orchestration using Azure Data Factory and Azure Synapse Analytics, including:

- Infrastructure as Code (Bicep & Terraform)
- ETL pipeline templates and patterns
- Linked services and dataset configurations
- Monitoring and alerting setup
- API testing and automation
- Best practices and design patterns

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Data Sources                             │
│  Azure SQL DB │ Blob Storage │ REST APIs │ Cosmos DB        │
└─────────────────────┬───────────────────────────────────────┘
                      │
        ┌─────────────▼──────────────┐
        │  Azure Data Factory        │
        │  - Copy Activities          │
        │  - Data Flows              │
        │  - Orchestration           │
        └─────────────┬──────────────┘
                      │
        ┌─────────────▼──────────────┐
        │  Azure Data Lake Gen2      │
        │  ┌──────────────────────┐  │
        │  │ Raw Layer            │  │
        │  ├──────────────────────┤  │
        │  │ Processed Layer      │  │
        │  ├──────────────────────┤  │
        │  │ Curated Layer        │  │
        │  └──────────────────────┘  │
        └─────────────┬──────────────┘
                      │
        ┌─────────────▼──────────────┐
        │  Synapse Analytics         │
        │  - Spark Pools             │
        │  - Notebooks               │
        │  - SQL Pools (optional)    │
        └─────────────┬──────────────┘
                      │
        ┌─────────────▼──────────────┐
        │  Consumption Layer         │
        │  Power BI │ APIs │ Apps    │
        └────────────────────────────┘
```

## Project Structure

```
synapse-datafactory-orchestration/
├── infrastructure/          # Infrastructure as Code
│   ├── bicep/              # Bicep templates
│   │   ├── main.bicep
│   │   ├── modules/        # Resource modules
│   │   └── parameters.json
│   └── terraform/          # Terraform configuration
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── modules/        # Terraform modules
├── pipelines/              # ADF/Synapse pipeline definitions
│   ├── pl_copy_blob_to_datalake.json
│   ├── pl_incremental_copy_sql.json
│   ├── pl_orchestration_master.json
│   └── pl_dynamic_copy_metadata.json
├── linkedservices/         # Linked service configurations
│   ├── ls_azure_sql.json
│   ├── ls_azure_blob_storage.json
│   ├── ls_azure_datalake_gen2.json
│   ├── ls_keyvault.json
│   └── ls_cosmos_db.json
├── datasets/               # Dataset definitions
│   ├── ds_source_blob.json
│   ├── ds_sink_adls.json
│   ├── ds_source_sql.json
│   └── ds_sink_parquet.json
├── templates/              # Reusable templates
│   ├── template_copy_activity.json
│   ├── template_error_handling.json
│   └── BEST_PRACTICES.md
├── monitoring/             # Monitoring and alerting
│   ├── alert_rules.json
│   ├── kql_queries.kql
│   └── workbook_template.json
├── tests/                  # API tests
│   ├── test_adf_api.py
│   ├── test_synapse_api.py
│   └── requirements.txt
└── README.md
```

## Prerequisites

- Azure subscription
- Azure CLI installed (`az --version`)
- Terraform >= 1.5.0 (for Terraform deployment)
- Azure Bicep CLI (for Bicep deployment)
- Python 3.8+ (for API tests)
- Azure AD permissions to create resources

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/synapse-datafactory-orchestration.git
cd synapse-datafactory-orchestration
```

### 2. Deploy Infrastructure

#### Option A: Using Bicep

```bash
# Login to Azure
az login

# Create resource group
az group create --name rg-synapse-df-dev --location australiaeast

# Get your Azure AD Object ID (for Synapse Admin)
OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)

# Update parameters file
cd infrastructure/bicep
# Edit parameters.json with your values

# Deploy
az deployment group create \
  --resource-group rg-synapse-df-dev \
  --template-file main.bicep \
  --parameters parameters.json \
  --parameters synapseAdminObjectId=$OBJECT_ID
```

#### Option B: Using Terraform

```bash
# Navigate to Terraform directory
cd infrastructure/terraform

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# Required: synapse_admin_object_id

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply deployment
terraform apply
```

### 3. Configure Data Factory

After infrastructure deployment:

1. Navigate to Azure Data Factory in the Azure Portal
2. Open the Data Factory Studio
3. Import pipeline definitions from the `pipelines/` folder
4. Import linked services from the `linkedservices/` folder
5. Import datasets from the `datasets/` folder
6. Update connection strings and Key Vault references

### 4. Run Tests

```bash
# Install Python dependencies
cd tests
pip install -r requirements.txt

# Set environment variables
export AZURE_SUBSCRIPTION_ID="your-subscription-id"
export AZURE_RESOURCE_GROUP="rg-synapse-df-dev"
export AZURE_DATA_FACTORY_NAME="your-adf-name"
export SYNAPSE_WORKSPACE_NAME="your-synapse-name"

# Run API tests
python test_adf_api.py
python test_synapse_api.py
```

## ETL Patterns

### 1. Simple Copy Pattern

Copies data from source to destination with basic transformations.

**Use Case**: Moving files from Blob Storage to Data Lake

**Pipeline**: `pl_copy_blob_to_datalake.json`

```json
{
  "activities": ["Copy data with wildcards and partitioning"]
}
```

### 2. Incremental Load Pattern

Loads only new or changed data using watermark tracking.

**Use Case**: Incremental data sync from SQL databases

**Pipeline**: `pl_incremental_copy_sql.json`

**Steps**:
1. Look up old watermark
2. Look up new watermark
3. Copy data between watermarks
4. Update watermark table

### 3. Metadata-Driven Pattern

Dynamically processes multiple tables based on metadata configuration.

**Use Case**: Bulk ingestion of multiple tables

**Pipeline**: `pl_dynamic_copy_metadata.json`

**Features**:
- Metadata control table
- Parallel processing with ForEach
- Dynamic source and destination
- Execution logging

### 4. Orchestration Pattern

Coordinates multiple pipelines with dependencies and error handling.

**Use Case**: End-to-end ETL workflow

**Pipeline**: `pl_orchestration_master.json`

**Workflow**:
1. Ingest raw data
2. Transform data (Spark)
3. Curate data (Spark)
4. Data quality checks
5. Send notifications

## Monitoring and Alerting

### Log Analytics Queries

Access pre-built KQL queries in `monitoring/kql_queries.kql`:

- Failed pipelines in last 24 hours
- Pipeline success rates
- Performance metrics
- Cost analysis
- Error analysis

### Azure Monitor Alerts

Configure alerts using `monitoring/alert_rules.json`:

- Pipeline failure alerts
- Long-running pipeline alerts
- High DIU consumption alerts
- Activity failure rate alerts

### Azure Workbooks

Deploy the monitoring workbook from `monitoring/workbook_template.json` for:

- Pipeline execution summary
- Status distribution
- Performance trends
- Data volume metrics

## Best Practices

### Design Principles

1. **Modularity**: Break complex workflows into smaller, reusable pipelines
2. **Parameterization**: Use parameters instead of hardcoded values
3. **Error Handling**: Implement retry logic and error notifications
4. **Logging**: Track execution details for troubleshooting
5. **Security**: Use Managed Identity and Key Vault

### Performance Optimization

- Use appropriate Data Integration Units (DIUs)
- Enable parallel processing with ForEach batching
- Implement incremental loads instead of full refreshes
- Use Parquet format for columnar storage
- Filter data at the source

### Security

- Enable Managed Identity for authentication
- Store secrets in Azure Key Vault
- Implement private endpoints for network isolation
- Use RBAC for access control
- Enable diagnostic logging

## API Operations

### Trigger Pipeline via REST API

```bash
# Get access token
ACCESS_TOKEN=$(az account get-access-token --resource https://management.azure.com --query accessToken -o tsv)

# Trigger pipeline
curl -X POST \
  "https://management.azure.com/subscriptions/{subscription-id}/resourceGroups/{rg}/providers/Microsoft.DataFactory/factories/{factory-name}/pipelines/{pipeline-name}/createRun?api-version=2018-06-01" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"parameters": {"sourceContainer": "raw"}}'
```

### Query Pipeline Runs

```bash
curl -X POST \
  "https://management.azure.com/subscriptions/{subscription-id}/resourceGroups/{rg}/providers/Microsoft.DataFactory/factories/{factory-name}/queryPipelineRuns?api-version=2018-06-01" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "lastUpdatedAfter": "2024-01-01T00:00:00Z",
    "lastUpdatedBefore": "2024-12-31T23:59:59Z"
  }'
```

## CI/CD Integration

### Azure DevOps Pipeline

```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: AzureCLI@2
    inputs:
      azureSubscription: 'Azure-Connection'
      scriptType: 'bash'
      scriptLocation: 'inlineScript'
      inlineScript: |
        az deployment group create \
          --resource-group $(ResourceGroup) \
          --template-file infrastructure/bicep/main.bicep \
          --parameters parameters.json
```

### GitHub Actions

```yaml
name: Deploy Data Factory

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      - name: Deploy Bicep
        run: |
          az deployment group create \
            --resource-group ${{ secrets.RESOURCE_GROUP }} \
            --template-file infrastructure/bicep/main.bicep
```

## Troubleshooting

### Common Issues

#### 1. Pipeline Timeout
- Increase timeout values in activity policy
- Optimize source queries
- Use incremental patterns for large datasets

#### 2. Authentication Failures
- Verify Managed Identity has proper permissions
- Check Key Vault access policies
- Validate connection strings

#### 3. Performance Issues
- Increase DIUs for copy activities
- Enable staging for large transfers
- Use parallel processing

#### 4. Expression Errors
- Validate expression syntax
- Check data types
- Use debug mode for testing

## Cost Optimization

- Right-size integration runtime
- Enable auto-pause for Synapse Spark pools
- Schedule large workloads during off-peak hours
- Use incremental loads to reduce data movement
- Monitor and optimize DIU consumption

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Resources

- [Azure Data Factory Documentation](https://docs.microsoft.com/azure/data-factory/)
- [Azure Synapse Analytics Documentation](https://docs.microsoft.com/azure/synapse-analytics/)
- [Data Factory REST API Reference](https://docs.microsoft.com/rest/api/datafactory/)
- [Synapse REST API Reference](https://docs.microsoft.com/rest/api/synapse/)

## License

MIT License - see LICENSE file for details

## Support

For issues and questions:
- Open an issue in GitHub
- Check the troubleshooting section
- Review Azure Data Factory documentation

---

**Built with Azure Data Factory & Synapse Analytics**
