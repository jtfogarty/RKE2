```mermaid
graph TD
    User[User\nhttp://ollama.documentresearch.dev:8080/api] -->|HTTP| PF

    subgraph PF[------------------------------------pfSense------------------------------------\nVIP: 10.10.100.7\n DNS: ollama]
        subgraph HAProxy
        HAP[istio frontend\nistio backend]
        end
    end

    HAP -->|Port 30354| KC

    subgraph KC[Kubernetes Cluster]
        IS1[Istio Ingress Gateway Node 1]
        IS2[Istio Ingress Gateway Node 2]
        IS3[Istio Ingress Gateway Node 3]
        OG[Ollama Gateway port 80]
        VS[Virtual Service]
        OS[Ollama Service]
        
        IS1 & IS2 & IS3 -->|HTTP| OG
        OG -->|HTTP| VS
        VS -->|Port 11434| OS
    end
```
