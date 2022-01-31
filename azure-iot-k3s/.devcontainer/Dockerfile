ARG UBUNTU_VERSION="20.04"
FROM ubuntu:${UBUNTU_VERSION}

ARG TERRAFORM_VERSION=1.0.11
ARG TFLINT_VERSION=0.29.1
ARG HELM_VERSION=3.6.3

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y install git unzip vim \
    curl zsh gnupg2 iputils-ping jq software-properties-common \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Install docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Terraform, tflint
RUN mkdir -p /tmp/docker-downloads \
    && curl -sSL -o /tmp/docker-downloads/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip /tmp/docker-downloads/terraform.zip \
    && mv terraform /usr/local/bin \
    && curl -sSL -o /tmp/docker-downloads/tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_darwin_amd64.zip \
    && unzip /tmp/docker-downloads/tflint.zip \
    && mv tflint /usr/local/bin \
    && rm -rf /tmp/docker-downloads

# Install helm
RUN mkdir -p /tmp/docker-downloads \
    && curl -sSL -o /tmp/docker-downloads/helm.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && tar -zxvf /tmp/docker-downloads/helm.tar.gz -C /tmp/docker-downloads/ \
    && mv /tmp/docker-downloads/linux-amd64/helm /usr/local/bin/helm \
    && rm -rf /tmp/docker-downloads

# Install az cli - if fails, docker system prune --force
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

ARG DEBIAN_FRONTEND=interactive
