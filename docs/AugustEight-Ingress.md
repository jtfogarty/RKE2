Certainly! I'll create a markdown document that explains how Ollama and Typesense are being ingressed, including their relationship with Traefik. 

```markdown
# Ingress Configuration for Ollama and Typesense

## Overview

Both Ollama and Typesense are using Kubernetes Ingress resources for routing external traffic to their respective services. Traefik is being used as the Ingress Controller in this cluster.

## Traefik Configuration

Traefik is deployed as a DaemonSet in the `traefik` namespace:

```yaml
Name:             traefik-01-rke2-traefik
Namespace:        traefik
Service:          traefik-01-rke2-traefik
Type:             NodePort
Ports:            80:30080/TCP, 443:30443/TCP
```

## HAProxy Frontend

An HAProxy instance is set up in front of the Kubernetes cluster to route traffic to Traefik:

```
frontend traefik
    bind            10.10.100.7:8080 name 10.10.100.7:8080   
    mode            http
    option          forwardfor
    default_backend traefik-backend_ipvANY
```

## Ollama Ingress

Ollama uses a standard Kubernetes Ingress resource:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ollama-gpu
  namespace: ollama
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
  - host: ollama.documentresearch.dev
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ollama-gpu
            port:
              number: 11434
```

## Typesense Ingress

Typesense also uses a standard Kubernetes Ingress resource:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: typesense
  namespace: typesense
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
  - host: typesense.documentresearch.dev
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: typesense-svc
            port: 
              number: 8108
```

## Traffic Flow

1. Client requests to `ollama.documentresearch.dev:8080` or `typesense.documentresearch.dev:8080` are resolved by DNS to the HAProxy IP (10.10.100.7).
2. HAProxy forwards these requests to one of the Kubernetes nodes on port 30080 (Traefik's NodePort).
3. Traefik receives the requests and routes them based on the Ingress rules:
   - Requests for `ollama.documentresearch.dev` are sent to the `ollama-gpu` service on port 11434.
   - Requests for `typesense.documentresearch.dev` are sent to the `typesense-svc` service on port 8108.
4. The respective services then forward the requests to the appropriate pods.

## Conclusion

Both Ollama and Typesense are indeed using Traefik as their Ingress Controller. The routing is configured using standard Kubernetes Ingress resources, which Traefik interprets and implements. This setup allows for consistent and manageable external access to both services through a common entrypoint.
```

This markdown document provides a clear overview of how Ollama and Typesense are being ingressed, confirming that they are both using Traefik as their Ingress Controller. The document includes details about the Traefik setup, HAProxy configuration, and the specific Ingress resources for both Ollama and Typesense, as well as an explanation of the traffic flow.
