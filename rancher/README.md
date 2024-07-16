# Rancher Storage Setup Ansible Playbook

This document explains the Ansible playbook used to set up Kubernetes storage (StorageClass and PersistentVolume) via the Rancher API.

## Overview

The playbook performs two main tasks:
1. Creates a StorageClass
2. Creates a PersistentVolume

It interacts with Rancher's API to accomplish these tasks, rather than directly with Kubernetes.

## Prerequisites

- Ansible installed on your local machine
- Access to a Rancher server
- A valid Rancher API token
- The ID of the cluster you're targeting in Rancher

## Playbook Structure

```yaml
---
- name: Setup Kubernetes Storage via Rancher
  hosts: localhost
  gather_facts: no
  vars:
    rancher_url: "{{ lookup('env', 'RANCHER_URL') }}"
    rancher_token: "{{ lookup('env', 'RANCHER_TOKEN') }}"
    cluster_id: "your-cluster-id"

  tasks:
    - name: Create StorageClass
      # ... (task details)

    - name: Create PersistentVolume
      # ... (task details)
```

## Variables

- `rancher_url`: The URL of your Rancher server
- `rancher_token`: Your Rancher API token
- `cluster_id`: The ID of the cluster in Rancher where you're creating the resources

These variables are set to use environment variables for security. You should set these environment variables before running the playbook:

```bash
export RANCHER_URL="https://your-rancher-server.com"
export RANCHER_TOKEN="your-api-token"
```

## Tasks

### 1. Create StorageClass

This task sends a POST request to Rancher's API to create a StorageClass.

Key points:
- Uses the `uri` module to send an HTTP request
- The URL is constructed using the Rancher URL and cluster ID
- The request body includes all the necessary StorageClass configuration
- Headers include the content type and authorization token

### 2. Create PersistentVolume

This task sends a POST request to Rancher's API to create a PersistentVolume.

Key points:
- Similar structure to the StorageClass task
- The request body includes the PersistentVolume specification
- Uses NFS for the volume type

## Running the Playbook

1. Save the playbook to a file (e.g., `rancher_storage_setup.yml`)
2. Set the environment variables for `RANCHER_URL` and `RANCHER_TOKEN`
3. Replace `your-cluster-id` in the playbook with your actual Rancher cluster ID
4. Run the playbook:
   ```
   ansible-playbook rancher_storage_setup.yml
   ```

## Security Considerations

- The playbook uses environment variables for sensitive data (URL and token) to avoid hardcoding these values
- In a production environment, consider using Ansible Vault for even better security

## Customization

You may need to adjust the following based on your specific setup:
- The StorageClass and PersistentVolume configurations
- The API endpoints if your Rancher version uses different URLs
- Add error handling and idempotency checks for production use

## Troubleshooting

If you encounter issues:
1. Verify your Rancher URL and token are correct
2. Ensure you have the necessary permissions in Rancher
3. Check Rancher's API documentation to ensure the endpoints are correct for your version
4. Review Rancher's logs for any error messages

Remember to test this playbook in a safe environment before using it in production.