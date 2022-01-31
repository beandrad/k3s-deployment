docker exec $CONTID kubectl get secret import-token-k3s-vm -n fleet-default -o 'jsonpath={.data.values}' | base64 --decode


curl https://edgek8s.blob.core.windows.net/staging/edge-kubernetes-crd-0.2.13.tgz --output edge-kubernetes-crd-0.2.13.tgz


# Install k3s on RPI: 
    curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --tls-san 192.168.0.195

# IoT Edge k8s

https://microsoft.github.io/iotedge-k8s-doc/introduction.html

Github public preview: https://github.com/Azure/iotedge/tree/edge-on-k8s-public-preview

# Install kubevirts and CDI in rpi
- https://github.com/Azure-Samples/IoT-Edge-K8s-KubeVirt-Deployment/

- issues: https://github.com/kubevirt/kubevirt/issues/3558 ARM32 or ARM64 not supported
experimental: https://kubevirt.io/user-guide/operations/installation/#experimental-arm64-developer-builds

- Update image tag: cdi: https://quay.io/repository/kubevirt/cdi-operator?tag=latest&tab=tags
https://github.com/kubevirt/containerized-data-importer/releases
    sed -i "s/v1.44.0/20220129_472c38e6-arm64/g" cdi-operator.yaml

    cdi version needs to be 20220120_7806e77b-arm64; otherwise wrong kube api API (seen in cdi-apiserver logs), maybe incompatible with version of k8s

- Install IoT edge / sets up config.toml: https://github.com/Azure/iotedge-vm-deploy/blob/1.2/cloud-init.txt

image: https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-arm64.img from https://cloud-images.ubuntu.com/bionic/current/

- Install Helm: mkdir -p /tmp/docker-downloads \
    && curl -sSL -o /tmp/docker-downloads/helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amr64.tar.gz \
    && tar -zxvf /tmp/docker-downloads/helm.tar.gz -C /tmp/docker-downloads/ \
    && mv /tmp/docker-downloads/linux-amd64/helm /usr/local/bin/helm \
    && rm -rf /tmp/docker-downloads

- virtualization needs to be enabled in node: https://github.com/kubevirt/kubevirt/issues/4748
https://linuxhint.com/enable_kvm_kernel_module_on_raspberry_pi_os/


- virtctl
export VERSION=v0.41.0
wget https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/virtctl-${VERSION}-linux-amd64
mv virtctl-v0.41.0-linux-amd64 /usr/local/bin/virtctl

expose port 22: virtctl expose vm aziot-edge-kubevirt-linux --port=22 --name=aziot-edge-kubevirt-linux-ssh --type=NodePort
kubeclt get svc

- ssh setup to vmi: https://kubevirt.io/user-guide/virtual_machines/accessing_virtual_machines/#static-ssh-key-injection-via-cloud-init

- setup edge config
tags: https://mcr.microsoft.com/v2/azureiotedge-metrics-collector/tags/list

make sure route module name is correct (from module)
remove edge hub docker container

https://github.com/Azure/iotedge/issues/2880 storage for hubz
