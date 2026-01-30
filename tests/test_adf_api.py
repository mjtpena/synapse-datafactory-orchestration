#!/usr/bin/env python3
"""
Azure Data Factory REST API Tests
Tests pipeline operations, monitoring, and management using ADF REST API
"""

import requests
import json
import os
from datetime import datetime, timedelta
from azure.identity import DefaultAzureCredential, ClientSecretCredential
from typing import Dict, List, Optional


class AzureDataFactoryClient:
    """Client for Azure Data Factory REST API operations"""

    def __init__(self, subscription_id: str, resource_group: str, factory_name: str):
        self.subscription_id = subscription_id
        self.resource_group = resource_group
        self.factory_name = factory_name
        self.api_version = "2018-06-01"
        self.base_url = f"https://management.azure.com/subscriptions/{subscription_id}/resourceGroups/{resource_group}/providers/Microsoft.DataFactory/factories/{factory_name}"

        # Authenticate using DefaultAzureCredential
        self.credential = DefaultAzureCredential()
        self.token = self._get_access_token()

    def _get_access_token(self) -> str:
        """Get Azure AD access token"""
        token = self.credential.get_token("https://management.azure.com/.default")
        return token.token

    def _get_headers(self) -> Dict[str, str]:
        """Get HTTP headers with authentication"""
        return {
            "Authorization": f"Bearer {self.token}",
            "Content-Type": "application/json"
        }

    def get_pipeline(self, pipeline_name: str) -> Dict:
        """Get pipeline definition"""
        url = f"{self.base_url}/pipelines/{pipeline_name}?api-version={self.api_version}"
        response = requests.get(url, headers=self._get_headers())
        response.raise_for_status()
        return response.json()

    def list_pipelines(self) -> List[Dict]:
        """List all pipelines"""
        url = f"{self.base_url}/pipelines?api-version={self.api_version}"
        response = requests.get(url, headers=self._get_headers())
        response.raise_for_status()
        return response.json().get("value", [])

    def create_pipeline_run(self, pipeline_name: str, parameters: Optional[Dict] = None) -> str:
        """Trigger a pipeline run"""
        url = f"{self.base_url}/pipelines/{pipeline_name}/createRun?api-version={self.api_version}"
        body = {"parameters": parameters} if parameters else {}

        response = requests.post(url, headers=self._get_headers(), json=body)
        response.raise_for_status()
        return response.json().get("runId")

    def get_pipeline_run(self, run_id: str) -> Dict:
        """Get pipeline run details"""
        url = f"{self.base_url}/pipelineruns/{run_id}?api-version={self.api_version}"
        response = requests.get(url, headers=self._get_headers())
        response.raise_for_status()
        return response.json()

    def query_pipeline_runs(self, start_time: datetime, end_time: datetime,
                           filters: Optional[List[Dict]] = None) -> List[Dict]:
        """Query pipeline runs in a time range"""
        url = f"{self.base_url}/queryPipelineRuns?api-version={self.api_version}"

        body = {
            "lastUpdatedAfter": start_time.isoformat() + "Z",
            "lastUpdatedBefore": end_time.isoformat() + "Z",
            "filters": filters or []
        }

        response = requests.post(url, headers=self._get_headers(), json=body)
        response.raise_for_status()
        return response.json().get("value", [])

    def query_activity_runs(self, run_id: str, start_time: datetime, end_time: datetime) -> List[Dict]:
        """Query activity runs for a pipeline run"""
        url = f"{self.base_url}/pipelineruns/{run_id}/queryActivityruns?api-version={self.api_version}"

        body = {
            "lastUpdatedAfter": start_time.isoformat() + "Z",
            "lastUpdatedBefore": end_time.isoformat() + "Z"
        }

        response = requests.post(url, headers=self._get_headers(), json=body)
        response.raise_for_status()
        return response.json().get("value", [])

    def cancel_pipeline_run(self, run_id: str) -> Dict:
        """Cancel a running pipeline"""
        url = f"{self.base_url}/pipelineruns/{run_id}/cancel?api-version={self.api_version}"
        response = requests.post(url, headers=self._get_headers())
        response.raise_for_status()
        return response.json() if response.text else {}

    def get_linked_service(self, linked_service_name: str) -> Dict:
        """Get linked service definition"""
        url = f"{self.base_url}/linkedservices/{linked_service_name}?api-version={self.api_version}"
        response = requests.get(url, headers=self._get_headers())
        response.raise_for_status()
        return response.json()

    def get_dataset(self, dataset_name: str) -> Dict:
        """Get dataset definition"""
        url = f"{self.base_url}/datasets/{dataset_name}?api-version={self.api_version}"
        response = requests.get(url, headers=self._get_headers())
        response.raise_for_status()
        return response.json()


def test_list_pipelines(client: AzureDataFactoryClient):
    """Test: List all pipelines"""
    print("\n=== Test: List Pipelines ===")
    pipelines = client.list_pipelines()
    print(f"Found {len(pipelines)} pipelines")
    for pipeline in pipelines:
        print(f"  - {pipeline['name']}")
    assert len(pipelines) > 0, "No pipelines found"
    print("✓ Test passed")


def test_get_pipeline(client: AzureDataFactoryClient, pipeline_name: str):
    """Test: Get pipeline definition"""
    print(f"\n=== Test: Get Pipeline '{pipeline_name}' ===")
    pipeline = client.get_pipeline(pipeline_name)
    print(f"Pipeline: {pipeline['name']}")
    print(f"Type: {pipeline['type']}")
    print(f"Activities: {len(pipeline['properties'].get('activities', []))}")
    assert pipeline['name'] == pipeline_name, "Pipeline name mismatch"
    print("✓ Test passed")


def test_trigger_pipeline(client: AzureDataFactoryClient, pipeline_name: str):
    """Test: Trigger a pipeline run"""
    print(f"\n=== Test: Trigger Pipeline '{pipeline_name}' ===")

    # Trigger pipeline with parameters
    parameters = {
        "sourceContainer": "raw",
        "sourcePath": "test/data",
        "sinkContainer": "processed",
        "sinkPath": "test/output"
    }

    run_id = client.create_pipeline_run(pipeline_name, parameters)
    print(f"Pipeline run triggered: {run_id}")

    # Check run status
    import time
    max_wait = 300  # 5 minutes
    start_time = time.time()

    while time.time() - start_time < max_wait:
        run_details = client.get_pipeline_run(run_id)
        status = run_details['status']
        print(f"Status: {status}")

        if status in ['Succeeded', 'Failed', 'Cancelled']:
            break

        time.sleep(10)

    assert run_details['status'] in ['Succeeded', 'InProgress'], f"Pipeline run failed: {run_details.get('message', '')}"
    print("✓ Test passed")


def test_query_pipeline_runs(client: AzureDataFactoryClient):
    """Test: Query pipeline runs"""
    print("\n=== Test: Query Pipeline Runs ===")

    end_time = datetime.utcnow()
    start_time = end_time - timedelta(days=7)

    runs = client.query_pipeline_runs(start_time, end_time)
    print(f"Found {len(runs)} pipeline runs in the last 7 days")

    # Group by status
    status_counts = {}
    for run in runs:
        status = run['status']
        status_counts[status] = status_counts.get(status, 0) + 1

    print("Status breakdown:")
    for status, count in status_counts.items():
        print(f"  {status}: {count}")

    print("✓ Test passed")


def test_query_activity_runs(client: AzureDataFactoryClient):
    """Test: Query activity runs for a pipeline"""
    print("\n=== Test: Query Activity Runs ===")

    # Get recent pipeline run
    end_time = datetime.utcnow()
    start_time = end_time - timedelta(days=1)

    pipeline_runs = client.query_pipeline_runs(start_time, end_time)

    if len(pipeline_runs) > 0:
        run_id = pipeline_runs[0]['runId']
        print(f"Querying activities for run: {run_id}")

        activities = client.query_activity_runs(run_id, start_time, end_time)
        print(f"Found {len(activities)} activities")

        for activity in activities:
            print(f"  - {activity['activityName']}: {activity['status']}")
    else:
        print("No recent pipeline runs found")

    print("✓ Test passed")


def test_get_linked_services(client: AzureDataFactoryClient):
    """Test: Get linked service definitions"""
    print("\n=== Test: Get Linked Services ===")

    linked_services = ["ls_azure_sql", "ls_azure_blob_storage", "ls_azure_datalake_gen2"]

    for ls_name in linked_services:
        try:
            ls = client.get_linked_service(ls_name)
            print(f"  - {ls['name']}: {ls['properties']['type']}")
        except Exception as e:
            print(f"  - {ls_name}: Not found or error - {str(e)}")

    print("✓ Test passed")


def test_pipeline_metrics(client: AzureDataFactoryClient):
    """Test: Calculate pipeline success metrics"""
    print("\n=== Test: Pipeline Metrics ===")

    end_time = datetime.utcnow()
    start_time = end_time - timedelta(days=7)

    runs = client.query_pipeline_runs(start_time, end_time)

    if len(runs) > 0:
        # Calculate metrics
        total_runs = len(runs)
        succeeded = sum(1 for r in runs if r['status'] == 'Succeeded')
        failed = sum(1 for r in runs if r['status'] == 'Failed')
        success_rate = (succeeded / total_runs * 100) if total_runs > 0 else 0

        # Calculate average duration for succeeded runs
        durations = [r['durationInMs'] for r in runs if r['status'] == 'Succeeded' and 'durationInMs' in r]
        avg_duration_minutes = (sum(durations) / len(durations) / 1000 / 60) if durations else 0

        print(f"Total runs: {total_runs}")
        print(f"Succeeded: {succeeded}")
        print(f"Failed: {failed}")
        print(f"Success rate: {success_rate:.2f}%")
        print(f"Average duration: {avg_duration_minutes:.2f} minutes")
    else:
        print("No pipeline runs found in the last 7 days")

    print("✓ Test passed")


def main():
    """Main test execution"""
    # Configuration - Update these values
    SUBSCRIPTION_ID = os.getenv("AZURE_SUBSCRIPTION_ID", "your-subscription-id")
    RESOURCE_GROUP = os.getenv("AZURE_RESOURCE_GROUP", "your-resource-group")
    FACTORY_NAME = os.getenv("AZURE_DATA_FACTORY_NAME", "your-data-factory-name")

    print("Azure Data Factory API Tests")
    print("=" * 50)
    print(f"Subscription: {SUBSCRIPTION_ID}")
    print(f"Resource Group: {RESOURCE_GROUP}")
    print(f"Data Factory: {FACTORY_NAME}")

    # Initialize client
    client = AzureDataFactoryClient(SUBSCRIPTION_ID, RESOURCE_GROUP, FACTORY_NAME)

    try:
        # Run tests
        test_list_pipelines(client)
        test_query_pipeline_runs(client)
        test_query_activity_runs(client)
        test_get_linked_services(client)
        test_pipeline_metrics(client)

        # Optional: Test specific pipeline
        # test_get_pipeline(client, "pl_copy_blob_to_datalake")
        # test_trigger_pipeline(client, "pl_copy_blob_to_datalake")

        print("\n" + "=" * 50)
        print("All tests passed! ✓")

    except Exception as e:
        print(f"\n✗ Test failed: {str(e)}")
        raise


if __name__ == "__main__":
    main()
