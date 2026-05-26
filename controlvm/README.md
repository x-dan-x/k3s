# Control VM Bootstrap

This directory contains the bootstrap script used to configure the
control-centre VM for managing the Kubernetes cluster.

## Usage

Run on a fresh Ubuntu 26.04 VM:

    chmod +x bootstrap-control-vm.sh
    ./bootstrap-control-vm.sh

After installation, restart your shell:

    source ~/.bashrc

## Tools Installed

- kubectl
- helm
- kustomize
- ansible
- sops
- age
- yq
- kubectx / kubens
- git, curl, wget, jq, python3, ssh tools

This VM is used to:
- Provision nodes via Ansible
- Deploy Kubernetes resources
- Encrypt secrets with SOPS
- Manage the GitOps repository