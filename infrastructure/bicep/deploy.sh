#!/bin/bash
# Deploy Azure Data Factory and Synapse infrastructure using Bicep

set -e

# Configuration
RESOURCE_GROUP="rg-synapse-df-dev"
LOCATION="australiaeast"
DEPLOYMENT_NAME="synapse-df-deployment-$(date +%Y%m%d-%H%M%S)"

echo "==================================="
echo "Deploying Synapse Data Factory Infrastructure"
echo "==================================="
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "Error: Azure CLI is not installed. Please install it first."
    exit 1
fi

# Login check
echo "Checking Azure login..."
if ! az account show &> /dev/null; then
    echo "Please login to Azure..."
    az login
fi

# Get current user's Object ID for Synapse Admin
echo "Getting Azure AD Object ID..."
OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)
echo "Using Object ID: $OBJECT_ID"

# Create resource group if it doesn't exist
echo ""
echo "Creating resource group..."
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --output table

# Validate deployment
echo ""
echo "Validating Bicep template..."
az deployment group validate \
    --resource-group $RESOURCE_GROUP \
    --template-file main.bicep \
    --parameters parameters.json \
    --parameters synapseAdminObjectId=$OBJECT_ID

# Deploy infrastructure
echo ""
echo "Deploying infrastructure..."
echo "Deployment name: $DEPLOYMENT_NAME"
echo ""

az deployment group create \
    --resource-group $RESOURCE_GROUP \
    --name $DEPLOYMENT_NAME \
    --template-file main.bicep \
    --parameters parameters.json \
    --parameters synapseAdminObjectId=$OBJECT_ID \
    --output table

# Get deployment outputs
echo ""
echo "Deployment completed! Retrieving outputs..."
echo ""

az deployment group show \
    --resource-group $RESOURCE_GROUP \
    --name $DEPLOYMENT_NAME \
    --query properties.outputs \
    --output json

echo ""
echo "==================================="
echo "Deployment completed successfully!"
echo "==================================="
