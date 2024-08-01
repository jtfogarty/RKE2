# Troubleshooting GPU Integration in RKE2 Cluster

## Background

We encountered issues with GPU integration in an RKE2 cluster. The primary symptom was the inability to use NVIDIA GPUs within Kubernetes pods, despite the GPUs being recognized on the host system.

## Troubleshooting Process

### 1. Verifying GPU Visibility on Host

We first confirmed that the NVIDIA GPU was visible and functional on the host system using `nvidia-smi`. This step established that the GPU drivers were correctly installed and the hardware was recognized at the system level.

### 2. Checking RKE2 and Containerd Configuration

We examined the RKE2 and containerd configuration files to ensure that the NVIDIA runtime was properly configured. The relevant configurations were found in:

- `/etc/rancher/rke2/config.yaml`
- `/var/lib/rancher/rke2/agent/etc/containerd/config.toml`

These files showed that the NVIDIA runtime was set as the default runtime for containerd.

### 3. Using crictl for Direct Container Testing

We decided to use `crictl` to test GPU accessibility at the container runtime level, bypassing Kubernetes. This approach allowed us to isolate whether the issue was with the container runtime or with Kubernetes.

The `crictl` command we used was:

```bash
sudo /var/lib/rancher/rke2/bin/crictl run --runtime=nvidia container-config.json pod-config.json
```
Errors Encountered with crictl
Initially, we encountered several errors when trying to run containers with `crictl`:

1. Calico networking errors
2. cgroup configuration errors

These errors occurred because:

- The default pod configuration was trying to set up networking, which isn't necessary for this test.
- The cgroup path wasn't correctly formatted for systemd cgroups.

#### Fix for crictl Errors
We resolved these issues by:

1. Modifying the pod configuration to use host networking.
2. Adjusting the cgroup configuration to be compatible with systemd cgroups.

The final working pod configuration looked like this:

```json
{
  "metadata": {
    "name": "nvidia-pod-test-4"
  },
  "log_directory": "/tmp",
  "linux": {
    "cgroup_parent": "kubepods-besteffort.slice",
    "security_context": {
      "namespace_options": {
        "network": 2
      }
    }
  }
}
```

### 4. Verifying GPU Access in Container
Once we successfully ran a container using `crictl`, we verified GPU access by checking the container logs, which showed the output of `nvidia-smi`.

## Comparison with Kubernetes Pod
The `crictl` approach allowed us to test GPU accessibility at a lower level, directly interfacing with the container runtime. This is in contrast to running a pod in Kubernetes, which involves additional layers of abstraction and resource management.
Testing with `crictl` helped isolate the issue to the container runtime level, confirming that GPUs were accessible to containers when properly configured.
What We Missed
The ultimate solution was to add `runtimeClass: nvidia` to the Helm chart under the operator node. This indicates that while our troubleshooting confirmed GPU accessibility at the container level, we missed the connection between the container runtime and Kubernetes' understanding of how to use that runtime.
The `runtimeClass` specification in Kubernetes is what tells the system which runtime to use for specific pods. By not specifying this, Kubernetes wasn't aware that it should be using the NVIDIA runtime for GPU workloads.

## Lessons Learned
1. Always check the Kubernetes configurations, especially `runtimeClass`, when dealing with specialized hardware like GPUs.
2. Low-level testing (like using `crictl`) can be valuable but may not catch higher-level configuration issues in Kubernetes.
3. When using operators or Helm charts for complex setups like GPU integration, review all configuration options carefully.

## Conclusion
While our troubleshooting process helped confirm GPU accessibility at the container level, the ultimate solution lay in properly configuring Kubernetes to use the correct runtime for GPU workloads. This experience underscores the importance of understanding the entire stack, from hardware to container runtime to Kubernetes configurations, when integrating specialized hardware in a Kubernetes environment.
