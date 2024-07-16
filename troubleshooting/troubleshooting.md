# Troubleshooting Guide

This document provides solutions to common issues you might encounter when setting up and running the RKE2 cluster with Rancher.

## Common Issues

### 1. Nodes Fail to Join the Cluster

**Symptoms**: Agent nodes are unable to join the cluster, or server nodes can't communicate with each other.

**Possible Solutions**:
- Verify that the `vip` in `all.yaml` is correctly set and accessible from all nodes.
- Check firewall rules to ensure necessary ports are open (6443 for Kubernetes API, 9345 for RKE2).
- Verify that the `rke2_token` is correctly distributed to all nodes.

### 2. Rancher Deployment Fails

**Symptoms**: Rancher pods fail to start or become ready.

**Possible Solutions**:
- Check if cert-manager is properly installed and running.
- Verify that the `rancher_hostname` is correctly set and resolvable.
- Inspect Rancher pod logs for specific error messages.

### 3. MetalLB Configuration Issues

**Symptoms**: Services of type LoadBalancer remain in pending state.

**Possible Solutions**:
- Verify that the `lb_range` in `all.yaml` doesn't conflict with existing network configurations.
- Check MetalLB pod logs for configuration errors.
- Ensure the specified IP range is available and not used by other services.

### 4. NFS Provisioner Issues

**Symptoms**: PersistentVolumeClaims remain in pending state.

**Possible Solutions**:
- Verify that the NFS server is accessible from all cluster nodes.
- Check if the NFS path specified in the configuration exists and has correct permissions.
- Inspect the nfs-subdir-external-provisioner pod logs for specific error messages.

## Debugging Steps

1. **Check Node Status**: 
   ```
   kubectl get nodes
   ```

2. **View Pod Status**:
   ```
   kubectl get pods --all-namespaces
   ```

3. **Check Service Status**:
   ```
   kubectl get services --all-namespaces
   ```

4. **View Logs**:
   ```
   kubectl logs -n <namespace> <pod-name>
   ```

5. **Describe Resources**:
   ```
   kubectl describe <resource-type> <resource-name> -n <namespace>
   ```

## Running Health Checks

You can use the provided `rancher_health_check.yaml` playbook in the `troubleshooting` directory to perform a series of health checks on your cluster:

```
ansible-playbook -i inventory/hosts.ini troubleshooting/rancher_health_check.yaml
```

This will check various aspects of your cluster setup and provide diagnostic information.

If you encounter issues not covered in this guide, please consult the official [RKE2 documentation](https://docs.rke2.io/) and [Rancher documentation](https://rancher.com/docs/rancher/v2.x/en/).
