# Add Server Role

This role is responsible for adding and configuring additional server nodes to an RKE2 Kubernetes cluster.

## Tasks

The main tasks performed by this role (as defined in `tasks/main.yaml`) are:

1. Deploy RKE2 server configuration to all servers.
2. Wait for the cluster API to be ready.
3. Ensure all RKE2 servers are enabled and running.
4. Verify RKE2 server is running on all server nodes.

## Templates

- `rke2-server-config.j2`: Template for RKE2 server configuration

This template configures:
- Kubeconfig write mode
- Cluster join token
- API server address
- TLS SAN entries (including VIP and all server IPs)
- Node labels

## Variables

Key variables used in this role:

- `vip`: Virtual IP address for the Kubernetes API server (defined in `group_vars/all.yaml`)
- `rke2_token`: The token used for node authentication
- `ansible_user`: The user for SSH connections and command execution
- `hostvars`: Ansible's host variables, used to access individual server details

## Tags

This role doesn't use specific tags, but it's part of the overall RKE2 installation process.

## Usage

This role is typically included in the main playbook and runs on all server nodes. It configures servers to join the existing cluster.

## Notes

- This role now applies to all server nodes, including the first one.
- The role uses the VIP (Virtual IP) configured in pfSense for load balancing.
- The role now includes a verification step to ensure the RKE2 server is running on all nodes.

## Dependencies

- Requires the `rke2-prepare` role to be run first.
- Depends on pfSense for load balancing.

## Configuration

Ensure that the following are properly configured:
1. The `vip` variable in `group_vars/all.yaml` matches your pfSense configuration.
2. pfSense HAProxy is set up to forward traffic to all server nodes on port 9345.
3. Network allows traffic from Kubernetes nodes to the VIP address for API server communication.

## Potential Improvements

1. Implement a health check for the RKE2 cluster after all servers are added.
2. Add error handling and retry logic for server join process.
3. Implement a rollback mechanism in case of failed server additions.
4. Add more granular tagging for better task selection.
