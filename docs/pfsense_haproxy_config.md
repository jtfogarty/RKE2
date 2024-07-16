# pfSense HAProxy Configuration for RKE2 and Rancher

This document outlines the configuration of HAProxy in pfSense for RKE2 Kubernetes cluster and Rancher management interface.

## Frontends

### 1. RKE2-K8S-SERVER

- **Bind Address**: 10.10.100.2:9345
- **Mode**: TCP
- **Max Connections**: Default
- **Timeout Client**: 30000ms
- **Default Backend**: rke-control-plane-server_ipvANY

### 2. RKE2-K8S-API

- **Bind Address**: 10.10.100.2:6443
- **Mode**: TCP
- **Max Connections**: 100
- **Timeout Client**: 30000ms
- **Default Backend**: rke-control-plane-api_ipvANY

### 3. rancher-frontend

- **Bind Address**: 104.52.20.73:443
- **Mode**: TCP
- **Timeout Client**: 30000ms
- **ACL**: 
  - Name: rancher_acl
  - Expression: req.ssl_sni -i rancher.docure.ai
- **Actions**:
  - **cp request**: content accept if { req.ssl_hello_type 1 }
  - TCP Inspection Delay: 5s
  - Use Backend: rancher-backend_ipvANY if rancher_acl
- **Default Backend**: 
## Backends

### 1. rke-control-plane-server_ipvANY

- **Mode**: TCP
- **Balance Algorithm**: Round Robin
- **Timeout Connect**: 30000ms
- **Timeout Server**: 30000ms
- **Retries**: 5
- **Check**: TCP Check
- **Servers**:
  - ks8-rancher-01: 10.10.100.5:9345
  - ks8-rancher-02: 10.10.100.6:9345
  - ks8-rancher-03: 10.10.100.8:9345


> ### :warning: **Note:**
> **After reinstalling the entire cluster, the below healthcheck no longer works.**

### 2. rke-control-plane-api_ipvANY
- **Mode**: TCP
- **Balance Algorithm**: Round Robin
- **Timeout Connect**: 30000ms
- **Timeout Server**: 30000ms
- **Retries**: 5
- **Check**: HTTP Check
  - Method: GET
  - URI: /healthz
  - Version: HTTP/2
  - Headers: 
    - Authorization: "Bearer long-string"
- **Expected Status**: 200
- **Servers**:
  - ks8-rancher-01: 10.10.100.5:6443
  - ks8-rancher-02: 10.10.100.6:6443
  - ks8-rancher-03: 10.10.100.8:6443

### 3. rancher-backend_ipvANY

- **Mode**: TCP
- **Balance Algorithm**: Least Connections
- **Timeout Connect**: 300000ms
- **Timeout Server**: 900000ms
- **Retries**: 5
- **Pass Thru**:
  - stick-table type ip size 200k expire 30m
  - stick on src
- **Servers**:
  - ks8-rancher-01: 10.10.100.5:443
  - ks8-rancher-02: 10.10.100.6:443
  - ks8-rancher-03: 10.10.100.8:443
  - k8s-rancher-04: 10.10.100.9:443
  - k8s-rancher-05: 10.10.100.10:443
  - k8s-rancher-06: 10.10.100.11:443
  - k8s-rancher-07: 10.10.100.12:443
  - k8s-rancher-08: 10.10.100.13:443
  - k8s-rancher-09: 10.10.100.15:443

## Notes
- The RKE2-K8S-SERVER and RKE2-K8S-API frontends are used for the Kubernetes control plane communication.
- The rancher-frontend is used to access the Rancher management interface.
- SSL passthrough is used for the Rancher frontend, allowing end-to-end encryption.
- Health checks are implemented for the Kubernetes API servers to ensure high availability.
- The Rancher backend uses a least connections balancing algorithm to distribute load effectively among the worker nodes.