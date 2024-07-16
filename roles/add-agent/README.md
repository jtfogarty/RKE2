# Add Agent Role

This role is responsible for adding and configuring agent nodes to an RKE2 Kubernetes cluster using a pfSense load balancer for high availability.

## Tasks

The main tasks performed by this role (as defined in `tasks/main.yaml`) are:

1. Ensure RKE2 config directory exists
2. Download RKE2 agent installation script
3. Install RKE2 agent
4. Fetch rke2_token from first server node
5. Deploy RKE2 Agent Configuration
6. Create RKE2 agent service file
7. Ensure RKE2 agents are enabled and running
8. Restart rke2-agent service

## Templates

- `rke2-agent-config.j2`: Template for RKE2 agent configuration
- `rke2-agent.service.j2`: Template for RKE2 agent systemd service file

## Variables

Key variables used in this role:

- `groups['agent_nodes']`: Ansible group containing all agent nodes
- `hostvars[groups['server_nodes'][0]]['rke2_token']`: The token used for agents to join the cluster
- `vip`: The Virtual IP address managed by pfSense for load balancing
- `overwrite_agent_config`: Boolean flag to force overwrite of agent configuration

## Tags

- `addNFS`: Used for NFS-related tasks (not directly used in this role, but mentioned for completeness)

## Usage

This role is typically included in the main playbook and runs on all nodes in the 'agent_nodes' group. It configures agent nodes to join the existing cluster through the pfSense load balancer.

## Notes

- This role now includes the installation of the RKE2 agent, not just configuration.
- The agent configuration uses the token from the first server node to join the cluster.
- Agents are labeled with "agent=true" for easy identification in the cluster.
- The configuration uses the VIP (Virtual IP) managed by pfSense instead of pointing to a specific server node, ensuring high availability.
- Agents connect to the Kubernetes API server on port 9345, which is the standard port for RKE2 server-to-server communication.

## Dependencies

- Requires the server nodes to be properly initialized with RKE2.
- Depends on the first server node being correctly set up with a valid join token.
- Requires pfSense to be configured with the correct VIP and load balancing rules for the Kubernetes API server.

## Configuration

Ensure that the following are properly configured:
1. The 'agent_nodes' group in the Ansible inventory is correctly defined with all agent nodes.
2. The first server node is properly initialized and has a valid join token.
3. The `vip` variable is correctly set to the Virtual IP address configured in pfSense.
4. pfSense is configured to load balance traffic to the Kubernetes API server (port 9345) across all server nodes.

## Potential Improvements

1. Implement logic to handle different tokens for different agents if required in the future.
2. Add health checks or verification steps to ensure agents have successfully joined the cluster.
3. Consider adding logic to handle upgrades or reconfigurations of existing agent nodes.
4. Implement a rollback mechanism in case of failed agent installations or configurations.
5. Add more granular tagging for better task selection.

## Troubleshooting

If agents are unable to join the cluster:
1. Verify that the VIP is reachable from the agent nodes.
2. Check that pfSense is correctly load balancing traffic to all server nodes.
3. Ensure the join token is correct and hasn't expired.
4. Verify that the necessary ports (9345) are open in any firewalls between agents and the VIP.
5. Check the RKE2 agent logs for any error messages.
