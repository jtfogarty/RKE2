# RKE2 Prepare Role

This role is responsible for preparing the RKE2 configuration and systemd service files on both server and agent nodes.

## Tasks

The main tasks performed by this role (as defined in `tasks/main.yaml`) include:

1. Creating necessary directories for RKE2 configuration and token
2. Starting and enabling RKE2 server on the first node
3. Waiting for and fetching the node token
4. Distributing the RKE2 token to all nodes
5. Configuring and starting RKE2 on nodes 2 and 3
6. Deploying RKE2 server and agent configurations
7. Creating systemd service files for RKE2 server and agent
8. Setting up kubectl and kubeconfig

## Templates

1. `rke2-agent.service.j2`: Systemd service file for RKE2 agent
2. `rke2-server-config.j2`: Configuration file for RKE2 server
3. `rke2-server.service.j2`: Systemd service file for RKE2 server

## Variables

This role uses variables defined in `inventory/group_vars/all.yaml`, including:

- `vip`: The Virtual IP address managed by pfSense for load balancing
- `cluster_cidr`: Custom CIDR for cluster network
- `service_cidr`: Custom CIDR for service network
- `rke2_token`: The token used for node authentication

## Tags

This role doesn't use specific tags, but it's part of the overall RKE2 installation process.

## Usage

This role should be applied to all nodes in the cluster, with specific tasks conditionally executed for server or agent nodes.

## Notes

- The RKE2 server is only enabled and started on the first server node initially.
- The node token is fetched from the first server node and distributed to all nodes.
- kubectl is set up for use on all server nodes.
- The kubeconfig file is copied and modified for user access on all server nodes.

## Potential Improvements

1. Implement error handling for cases where the node token or kubectl isn't available within the expected timeframe.
2. Consider parameterizing more values in the templates, such as the Kubernetes domain name.
3. Add tasks to verify the successful setup of RKE2 on each node.
4. Implement logic to handle upgrades or reconfigurations of existing setups.
5. Add more granular tagging for better task selection.
6. Implement a rollback mechanism in case of failed setups or upgrades.
