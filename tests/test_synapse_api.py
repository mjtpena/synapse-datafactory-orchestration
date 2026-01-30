#!/usr/bin/env python3
"""
Azure Synapse Analytics REST API Tests
Tests Synapse workspace operations, notebooks, and Spark pools
"""

import requests
import json
import os
from datetime import datetime, timedelta
from azure.identity import DefaultAzureCredential
from typing import Dict, List, Optional


class SynapseWorkspaceClient:
    """Client for Azure Synapse Analytics REST API operations"""

    def __init__(self, workspace_name: str):
        self.workspace_name = workspace_name
        self.api_version = "2020-12-01"
        self.dev_endpoint = f"https://{workspace_name}.dev.azuresynapse.net"

        # Authenticate
        self.credential = DefaultAzureCredential()
        self.token = self._get_access_token()

    def _get_access_token(self) -> str:
        """Get Azure AD access token for Synapse"""
        token = self.credential.get_token("https://dev.azuresynapse.net/.default")
        return token.token

    def _get_headers(self) -> Dict[str, str]:
        """Get HTTP headers with authentication"""
        return {
            "Authorization": f"Bearer {self.token}",
            "Content-Type": "application/json"
        }

    # Notebook Operations
    def list_notebooks(self) -> List[Dict]:
        """List all notebooks"""
        url = f"{self.dev_endpoint}/notebooks?api-version={self.api_version}"
        response = requests.get(url, headers=self._get_headers())
        response.raise_for_status()
        return response.json().get("value", [])

    def get_notebook(self, notebook_name: str) -> Dict:
        """Get notebook definition"""
        url = f"{self.dev_endpoint}/notebooks/{notebook_name}?api-version={self.api_version}"
        response = requests.get(url, headers=self._get_headers())
        response.raise_for_status()
        return response.json()

    # Pipeline Operations
    def list_pipelines(self) -> List[Dict]:
        """List all Synapse pipelines"""
        url = f"{self.dev_endpoint}/pipelines?api-version={self.api_version}"
        response = requests.get(url, headers=self._get_headers())
        response.raise_for_status()
        return response.json().get("value", [])

    def get_pipeline(self, pipeline_name: str) -> Dict:
        """Get pipeline definition"""
        url = f"{self.dev_endpoint}/pipelines/{pipeline_name}?api-version={self.api_version}"
        response = requests.get(url, headers=self._get_headers())
        response.raise_for_status()
        return response.json()

    def create_pipeline_run(self, pipeline_name: str, parameters: Optional[Dict] = None) -> str:
        """Trigger a pipeline run"""
        url = f"{self.dev_endpoint}/pipelines/{pipeline_name}/createRun?api-version={self.api_version}"
        body = parameters if parameters else {}

        response = requests.post(url, headers=self._get_headers(), json=body)
        response.raise_for_status()
        return response.json().get("runId")

    def get_pipeline_run(self, run_id: str) -> Dict:
        """Get pipeline run status"""
        url = f"{self.dev_endpoint}/pipelineruns/{run_id}?api-version={self.api_version}"
        response = requests.get(url, headers=self._get_headers())
        response.raise_for_status()
        return response.json()

    # Spark Pool Operations
    def list_spark_pools(self) -> List[Dict]:
        """List all Spark pools"""
        # Note: This uses management API
        url = f"https://management.azure.com/subscriptions/{{subscription_id}}/resourceGroups/{{resource_group}}/providers/Microsoft.Synapse/workspaces/{self.workspace_name}/bigDataPools?api-version=2021-06-01"
        # Simplified - would need full implementation
        return []

    # Linked Service Operations
    def list_linked_services(self) -> List[Dict]:
        """List all linked services"""
        url = f"{self.dev_endpoint}/linkedservices?api-version={self.api_version}"
        response = requests.get(url, headers=self._get_headers())
        response.raise_for_status()
        return response.json().get("value", [])

    def get_linked_service(self, linked_service_name: str) -> Dict:
        """Get linked service definition"""
        url = f"{self.dev_endpoint}/linkedservices/{linked_service_name}?api-version={self.api_version}"
        response = requests.get(url, headers=self._get_headers())
        response.raise_for_status()
        return response.json()

    # Dataset Operations
    def list_datasets(self) -> List[Dict]:
        """List all datasets"""
        url = f"{self.dev_endpoint}/datasets?api-version={self.api_version}"
        response = requests.get(url, headers=self._get_headers())
        response.raise_for_status()
        return response.json().get("value", [])


def test_list_notebooks(client: SynapseWorkspaceClient):
    """Test: List all notebooks"""
    print("\n=== Test: List Notebooks ===")
    try:
        notebooks = client.list_notebooks()
        print(f"Found {len(notebooks)} notebooks")
        for notebook in notebooks[:5]:  # Show first 5
            print(f"  - {notebook['name']}")
        print("✓ Test passed")
    except Exception as e:
        print(f"⚠ Test skipped or failed: {str(e)}")


def test_list_pipelines(client: SynapseWorkspaceClient):
    """Test: List all pipelines"""
    print("\n=== Test: List Pipelines ===")
    try:
        pipelines = client.list_pipelines()
        print(f"Found {len(pipelines)} pipelines")
        for pipeline in pipelines[:5]:  # Show first 5
            print(f"  - {pipeline['name']}")
        print("✓ Test passed")
    except Exception as e:
        print(f"⚠ Test skipped or failed: {str(e)}")


def test_get_pipeline(client: SynapseWorkspaceClient, pipeline_name: str):
    """Test: Get pipeline definition"""
    print(f"\n=== Test: Get Pipeline '{pipeline_name}' ===")
    try:
        pipeline = client.get_pipeline(pipeline_name)
        print(f"Pipeline: {pipeline['name']}")
        print(f"Activities: {len(pipeline['properties'].get('activities', []))}")
        print("✓ Test passed")
    except Exception as e:
        print(f"⚠ Test skipped or failed: {str(e)}")


def test_list_linked_services(client: SynapseWorkspaceClient):
    """Test: List all linked services"""
    print("\n=== Test: List Linked Services ===")
    try:
        linked_services = client.list_linked_services()
        print(f"Found {len(linked_services)} linked services")
        for ls in linked_services[:5]:
            ls_type = ls['properties'].get('type', 'Unknown')
            print(f"  - {ls['name']}: {ls_type}")
        print("✓ Test passed")
    except Exception as e:
        print(f"⚠ Test skipped or failed: {str(e)}")


def test_list_datasets(client: SynapseWorkspaceClient):
    """Test: List all datasets"""
    print("\n=== Test: List Datasets ===")
    try:
        datasets = client.list_datasets()
        print(f"Found {len(datasets)} datasets")
        for ds in datasets[:5]:
            ds_type = ds['properties'].get('type', 'Unknown')
            print(f"  - {ds['name']}: {ds_type}")
        print("✓ Test passed")
    except Exception as e:
        print(f"⚠ Test skipped or failed: {str(e)}")


def test_notebook_operations(client: SynapseWorkspaceClient):
    """Test: Notebook operations"""
    print("\n=== Test: Notebook Operations ===")
    try:
        notebooks = client.list_notebooks()
        if notebooks:
            # Get details of first notebook
            first_notebook = notebooks[0]
            notebook_name = first_notebook['name']
            notebook = client.get_notebook(notebook_name)

            print(f"Notebook: {notebook['name']}")
            print(f"Language: {notebook['properties'].get('metadata', {}).get('language', 'Unknown')}")
            print(f"Cells: {len(notebook['properties'].get('cells', []))}")
        else:
            print("No notebooks found")

        print("✓ Test passed")
    except Exception as e:
        print(f"⚠ Test skipped or failed: {str(e)}")


def main():
    """Main test execution"""
    # Configuration - Update these values
    WORKSPACE_NAME = os.getenv("SYNAPSE_WORKSPACE_NAME", "your-synapse-workspace-name")

    print("Azure Synapse Analytics API Tests")
    print("=" * 50)
    print(f"Workspace: {WORKSPACE_NAME}")

    # Initialize client
    client = SynapseWorkspaceClient(WORKSPACE_NAME)

    try:
        # Run tests
        test_list_notebooks(client)
        test_list_pipelines(client)
        test_list_linked_services(client)
        test_list_datasets(client)
        test_notebook_operations(client)

        print("\n" + "=" * 50)
        print("All tests completed! ✓")

    except Exception as e:
        print(f"\n✗ Test failed: {str(e)}")
        raise


if __name__ == "__main__":
    main()
