

> ### :warning: **Note:**
> **Not sure which one of the below is being used.**
```
cattle-system                            rancher-tls                                                     kubernetes.io/tls                             2      22h
cattle-system                            tls-rancher                                                     kubernetes.io/tls                             2      9h
cattle-system                            tls-rancher-ingress                                             kubernetes.io/tls                             3      9h
cattle-system                            tls-rancher-internal                                            kubernetes.io/tls                             2      9h
cattle-system                            tls-rancher-internal-ca                                         kubernetes.io/tls                             2      9h
```

```
kubectl create secret tls rancher-tls   --cert=cert.pem   --key=key.pem   -n cattle-system
helm upgrade rancher rancher-stable/rancher   --namespace cattle-system   --reuse-values   --set ingress.tls.source=secret   --set ingress.tls.secretName=rancher-tls
```


> ### :warning: **Note:**
> **it seems we have an answer, rancher-tls is the correct name**
```
helm get values rancher -n cattle-system
USER-SUPPLIED VALUES:
bootstrapPassword: TooManySecrets
extraEnv:
- name: CATTLE_UI_PLUGIN_SYSTEM
  value: '"true"'
hostname: rancher.documentresearch.dev
ingress:
  tls:
    secretName: rancher-tls
    source: secret
```