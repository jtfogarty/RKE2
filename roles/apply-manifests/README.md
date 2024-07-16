# Apply Manifests Role

This role is responsible for applying various manifests and configurations to the Kubernetes cluster after it has been set up with RKE2.

## Tasks

The main tasks performed by this role are:

1. Wait for Kubernetes nodes to be ready
2. Add nfs-subdir-external-provisioner Helm repository
3. Install nfs-subdir-external-provisioner
4. Deploy MetalLB and configure IP pool (currently commented out)
5. Deploy cert-manager
6. Deploy Rancher

## Templates

- `metallb-ippool.j2`: Template for MetalLB IP address pool configuration
- `rancher-values.j2`: Template for Rancher Helm values

## Variables

Key variables used in this role (defined in `group_vars/all.yaml`):

- `metallb_version`: Version of MetalLB to install
- `lb_range`: IP range for MetalLB to use for load balancer services
- `lb_pool_name`: Name of the MetalLB address pool
- `cert_manager_version`: Version of cert-manager to install
- `vip`: Virtual IP address for the Kubernetes API server
- `rancher_hostname`: Hostname for Rancher
- `rancher_bootstrap_password`: Initial password for Rancher

## Tags

- `addNFS`: Used for NFS-related tasks
- `metallb`: Used for MetalLB deployment tasks (currently commented out)
- `cert-manager`: Used for cert-manager deployment tasks
- `rancher`: Used for Rancher deployment tasks

## Notes

- The role now includes the installation of an NFS subdir external provisioner.
- MetalLB deployment is currently commented out. If needed, uncomment the relevant tasks.
- The role includes logic to remove existing components if `force_reinstall_components` is true.
- Rancher deployment now includes setting up UI plugins.

## Potential Improvements

1. Implement better error handling and retry logic for Helm installations.
2. Add health checks for deployed components.
3. Implement a rollback mechanism in case of failed deployments.
4. Add more granular tagging for better task selection.
5. Consider parameterizing more values, such as the NFS server details.

## Troubleshooting

- If components fail to install, check the Kubernetes logs and ensure all prerequisites are met.
- Verify that the NFS server is accessible and properly configured.
- Ensure that the `vip` and `rancher_hostname` variables are correctly set.
- Check that the required ports are open in any firewalls between components.
