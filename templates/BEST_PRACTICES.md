# Azure Data Factory & Synapse Pipeline Best Practices

## Design Principles

### 1. Modularity and Reusability
- **Use Parameters**: Make pipelines configurable with parameters instead of hardcoding values
- **Create Template Pipelines**: Build reusable pipeline templates for common patterns
- **Leverage Execute Pipeline Activity**: Break complex workflows into smaller, manageable pipelines
- **Use Linked Templates**: Share common activities across multiple pipelines

### 2. Error Handling and Resilience
- **Implement Retry Logic**: Configure appropriate retry policies for transient failures
- **Use Dependency Conditions**: Handle success, failure, completion, and skip scenarios
- **Add Error Notifications**: Integrate with Logic Apps or Azure Monitor for alerting
- **Log Errors to Database**: Maintain audit trail of failures for troubleshooting
- **Implement Circuit Breaker Pattern**: Prevent cascading failures in dependent systems

### 3. Performance Optimization
- **Use Parallel Execution**: Configure ForEach activities with batch processing
- **Optimize Copy Activity**:
  - Use Data Integration Units (DIUs) appropriately
  - Enable staging for large data transfers
  - Use PolyBase for Azure SQL DW
  - Partition data for parallel processing
- **Filter Early**: Apply WHERE clauses at source to reduce data movement
- **Compress Data**: Use Parquet or ORC for columnar storage
- **Use Incremental Load**: Implement watermark pattern instead of full loads

### 4. Security Best Practices
- **Use Managed Identity**: Avoid storing credentials in linked services
- **Store Secrets in Key Vault**: Never hardcode passwords or connection strings
- **Implement RBAC**: Use Azure AD and role-based access control
- **Enable Private Endpoints**: Restrict network access to Azure services
- **Encrypt Data**: Enable encryption at rest and in transit
- **Audit Access**: Enable diagnostic settings and log analytics

### 5. Monitoring and Observability
- **Enable Diagnostic Logs**: Send logs to Log Analytics workspace
- **Create Alerts**: Set up alerts for pipeline failures and performance issues
- **Use User Properties**: Tag activities with metadata for easier filtering
- **Implement Custom Logging**: Log key metrics to database or Application Insights
- **Build Dashboards**: Create monitoring dashboards in Azure Monitor or Power BI

### 6. Source Control and CI/CD
- **Use Git Integration**: Connect Data Factory to GitHub or Azure DevOps
- **Follow Branching Strategy**: Use feature branches and pull requests
- **Parameterize Environments**: Use ARM template parameters for dev/test/prod
- **Automate Deployment**: Implement CI/CD pipelines with Azure DevOps or GitHub Actions
- **Version Control**: Tag releases and maintain changelog

### 7. Data Lake Architecture
- **Implement Medallion Architecture**: Raw → Processed → Curated layers
- **Use Partitioning**: Organize data by date or other logical partitions
- **Implement Data Lifecycle**: Configure retention policies and archiving
- **Apply Data Governance**: Use Azure Purview for data cataloging
- **Maintain Metadata**: Create and maintain data dictionaries

### 8. Naming Conventions
- **Pipelines**: `pl_<purpose>_<source>_<destination>` (e.g., `pl_copy_sql_to_datalake`)
- **Datasets**: `ds_<source/sink>_<type>` (e.g., `ds_source_sql`, `ds_sink_parquet`)
- **Linked Services**: `ls_<service_type>` (e.g., `ls_azure_sql`, `ls_keyvault`)
- **Activities**: Use descriptive names with action verbs (e.g., `CopyCustomerData`, `TransformSalesData`)
- **Parameters**: Use camelCase (e.g., `containerName`, `folderPath`)

### 9. Testing Strategy
- **Unit Testing**: Test individual activities and expressions
- **Integration Testing**: Test end-to-end pipelines with sample data
- **Performance Testing**: Validate performance with production-like volumes
- **Regression Testing**: Automate testing with PowerShell or REST API
- **Data Quality Testing**: Implement data validation rules

### 10. Cost Optimization
- **Right-size Resources**: Use appropriate integration runtime sizes
- **Auto-pause Synapse Pools**: Enable auto-pause for Spark pools
- **Monitor DIU Usage**: Optimize Data Integration Units consumption
- **Schedule Off-peak Runs**: Run large workloads during off-peak hours
- **Clean Up Resources**: Delete unused pipelines and datasets
- **Use Spot VMs**: For non-critical workloads, use spot instances

## Common Patterns

### Pattern 1: Incremental Load with Watermark
```json
{
  "name": "IncrementalLoadPattern",
  "steps": [
    "1. Lookup old watermark value",
    "2. Lookup new watermark value",
    "3. Copy data between watermarks",
    "4. Update watermark table"
  ]
}
```

### Pattern 2: Metadata-Driven Copy
```json
{
  "name": "MetadataDrivenPattern",
  "steps": [
    "1. Lookup metadata control table",
    "2. ForEach table in metadata",
    "3. Copy table data dynamically",
    "4. Log success/failure to control table"
  ]
}
```

### Pattern 3: File Processing with Archive
```json
{
  "name": "FileProcessingPattern",
  "steps": [
    "1. Get list of files from source",
    "2. ForEach file, process data",
    "3. Move processed files to archive",
    "4. Send completion notification"
  ]
}
```

### Pattern 4: Data Validation and Quality Checks
```json
{
  "name": "DataQualityPattern",
  "steps": [
    "1. Copy data to staging area",
    "2. Run data quality notebook",
    "3. If valid, move to curated layer",
    "4. If invalid, move to error folder and alert"
  ]
}
```

### Pattern 5: Orchestration with Dependencies
```json
{
  "name": "OrchestrationPattern",
  "steps": [
    "1. Execute ingestion pipeline",
    "2. Execute transformation pipeline (on success)",
    "3. Execute aggregation pipeline (on success)",
    "4. Refresh Power BI dataset (on success)",
    "5. Send notification (on completion/failure)"
  ]
}
```

## Expressions and Functions

### Commonly Used Functions
- **Date/Time**: `utcNow()`, `formatDateTime()`, `addDays()`, `startOfDay()`
- **String**: `concat()`, `substring()`, `replace()`, `split()`
- **Logical**: `if()`, `and()`, `or()`, `equals()`
- **Conversion**: `string()`, `int()`, `float()`, `bool()`
- **Array**: `first()`, `last()`, `length()`, `join()`

### System Variables
- `@pipeline().Pipeline` - Current pipeline name
- `@pipeline().RunId` - Current run ID
- `@pipeline().DataFactory` - Data Factory name
- `@pipeline().TriggerTime` - Trigger execution time
- `@activity('ActivityName').output` - Activity output
- `@item()` - Current item in ForEach loop

## Troubleshooting Tips

1. **Copy Activity Failures**
   - Check source/sink connectivity
   - Verify schema compatibility
   - Review DIU allocation
   - Check for data type mismatches

2. **Performance Issues**
   - Increase DIUs for copy activities
   - Enable parallel processing
   - Use staging for large transfers
   - Optimize source queries

3. **Timeout Errors**
   - Increase timeout values
   - Break large operations into smaller chunks
   - Use incremental patterns
   - Optimize source system performance

4. **Authentication Failures**
   - Verify managed identity permissions
   - Check Key Vault access policies
   - Validate connection strings
   - Review firewall rules

5. **Expression Errors**
   - Validate expression syntax
   - Check data types
   - Use debug mode
   - Test with sample data
