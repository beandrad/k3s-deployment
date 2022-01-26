#!/bin/bash

upload() {
  # Wait for kubeconfig to exist, then upload to key vault
  retries=10

  while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do
    sleep 10
    if [ "$retries" = 0 ]; then
      fatal "Failed to create kubeconfig"
    fi
    ((retries--))
  done

  access_token=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2021-02-01&resource=https%3A%2F%2Fvault.azure.net' -H Metadata:true | jq -r ".access_token")

  curl -v -X PUT \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $${access_token}" \
    "${vault_url}secrets/kubeconfig?api-version=7.1" \
    --data-binary @- << EOF
{
  "value": "$(sed "s/127.0.0.1/${server_ip}/g" /etc/rancher/k3s/k3s.yaml)"
}
EOF
}

# install k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.23.2+k3s1 sh -
upload
