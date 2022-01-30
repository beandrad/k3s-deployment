# Multi-Cluster Helm Example

This example will deploy the [Kubernetes sample guestbook](https://github.com/kubernetes/examples/tree/master/guestbook/) application as
packaged as a Helm chart.
The app will be deployed into the `fleet-mc-helm-example` namespace.

```yaml
kind: GitRepo
apiVersion: fleet.cattle.io/v1alpha1
metadata:
  name: helm
  namespace: fleet-default
spec:
  repo: "https://github.com/beandrad/k3s-deployment.git"
  paths:
  - rancher/gitops/helm
  targets:
  - name: amd64
    clusterSelector:
      matchLabels:
        kubernetes.io/arch: amd64

  - name: arm64
    clusterSelector:
      matchLabels:
        kubernetes.io/arch: arm64
```
