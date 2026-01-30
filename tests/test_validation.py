#!/usr/bin/env python3
"""
Validation tests for Data Factory pipeline definitions
Tests JSON syntax, structure, and logical validation
"""

import json
import os
from pathlib import Path


def validate_json_file(file_path: str) -> bool:
    """Validate JSON file syntax"""
    try:
        with open(file_path, 'r') as f:
            json.load(f)
        return True
    except json.JSONDecodeError as e:
        print(f"  ✗ JSON Error: {str(e)}")
        return False
    except Exception as e:
        print(f"  ✗ Error: {str(e)}")
        return False


def test_pipeline_json_syntax():
    """Test: Validate all pipeline JSON files"""
    print("\n=== Test: Pipeline JSON Syntax ===")
    base_path = Path(__file__).parent.parent / "pipelines"
    pipelines = list(base_path.glob("*.json"))

    if not pipelines:
        print("  No pipeline files found")
        return

    all_valid = True
    for pipeline_file in pipelines:
        is_valid = validate_json_file(pipeline_file)
        status = "✓" if is_valid else "✗"
        print(f"  {status} {pipeline_file.name}")
        all_valid = all_valid and is_valid

    assert all_valid, "Some pipeline files have invalid JSON"
    print(f"\n✓ All {len(pipelines)} pipeline files are valid")


def test_linkedservice_json_syntax():
    """Test: Validate all linked service JSON files"""
    print("\n=== Test: Linked Service JSON Syntax ===")
    base_path = Path(__file__).parent.parent / "linkedservices"
    linked_services = list(base_path.glob("*.json"))

    if not linked_services:
        print("  No linked service files found")
        return

    all_valid = True
    for ls_file in linked_services:
        is_valid = validate_json_file(ls_file)
        status = "✓" if is_valid else "✗"
        print(f"  {status} {ls_file.name}")
        all_valid = all_valid and is_valid

    assert all_valid, "Some linked service files have invalid JSON"
    print(f"\n✓ All {len(linked_services)} linked service files are valid")


def test_dataset_json_syntax():
    """Test: Validate all dataset JSON files"""
    print("\n=== Test: Dataset JSON Syntax ===")
    base_path = Path(__file__).parent.parent / "datasets"
    datasets = list(base_path.glob("*.json"))

    if not datasets:
        print("  No dataset files found")
        return

    all_valid = True
    for ds_file in datasets:
        is_valid = validate_json_file(ds_file)
        status = "✓" if is_valid else "✗"
        print(f"  {status} {ds_file.name}")
        all_valid = all_valid and is_valid

    assert all_valid, "Some dataset files have invalid JSON"
    print(f"\n✓ All {len(datasets)} dataset files are valid")


def test_pipeline_structure():
    """Test: Validate pipeline structure"""
    print("\n=== Test: Pipeline Structure ===")
    base_path = Path(__file__).parent.parent / "pipelines"
    pipelines = list(base_path.glob("*.json"))

    for pipeline_file in pipelines:
        with open(pipeline_file, 'r') as f:
            pipeline = json.load(f)

        # Check required fields
        assert "name" in pipeline, f"Pipeline {pipeline_file.name} missing 'name' field"
        assert "properties" in pipeline, f"Pipeline {pipeline_file.name} missing 'properties' field"
        assert "activities" in pipeline["properties"], f"Pipeline {pipeline_file.name} missing 'activities' field"

        activities = pipeline["properties"]["activities"]
        print(f"  ✓ {pipeline['name']}: {len(activities)} activities")

    print("\n✓ All pipelines have valid structure")


def test_infrastructure_files():
    """Test: Validate infrastructure files exist"""
    print("\n=== Test: Infrastructure Files ===")
    base_path = Path(__file__).parent.parent / "infrastructure"

    # Check Bicep files
    bicep_main = base_path / "bicep" / "main.bicep"
    assert bicep_main.exists(), "Bicep main.bicep not found"
    print(f"  ✓ Bicep main template exists")

    # Check Terraform files
    tf_main = base_path / "terraform" / "main.tf"
    assert tf_main.exists(), "Terraform main.tf not found"
    print(f"  ✓ Terraform main configuration exists")

    print("\n✓ Infrastructure files validation passed")


def main():
    """Main test execution"""
    print("Data Factory Configuration Validation Tests")
    print("=" * 50)

    try:
        test_pipeline_json_syntax()
        test_linkedservice_json_syntax()
        test_dataset_json_syntax()
        test_pipeline_structure()
        test_infrastructure_files()

        print("\n" + "=" * 50)
        print("All validation tests passed! ✓")

    except Exception as e:
        print(f"\n✗ Test failed: {str(e)}")
        raise


if __name__ == "__main__":
    main()
