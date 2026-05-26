#!/usr/bin/env bash
set -euo pipefail

echo "=== Updating system packages ==="
sudo apt update -y
sudo apt upgrade -y

echo "=== Installing base utilities ==="
sudo apt install -y \
  curl \
  wget \
  git \
  unzip \
  jq \
  python3 \
  python3-pip \
  python3-venv \
  sshpass \
  software-properties-common

echo "=== Installing kubectl ==="
curl -fsSL https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl \
  -o kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

echo "=== Installing Helm ==="
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "=== Installing Kustomize ==="
KUSTOMIZE_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases/latest | jq -r '.tag_name')
curl -LO https://github.com/kubernetes-sigs/kustomize/releases/download/${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz
tar -xzf kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz
chmod +x kustomize
sudo mv kustomize /usr/local/bin/kustomize
rm kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz

echo "=== Installing Ansible ==="
sudo apt install -y ansible

echo "=== Installing age (for SOPS encryption) ==="
AGE_VERSION="v1.1.1"
curl -LO https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-amd64.tar.gz
tar -xzf age-${AGE_VERSION}-linux-amd64.tar.gz
sudo mv age/age /usr/local/bin/age
sudo mv age/age-keygen /usr/local/bin/age-keygen
rm -rf age age-${AGE_VERSION}-linux-amd64.tar.gz

echo "=== Installing SOPS ==="
# Using a fixed version to avoid GitHub redirect issues
SOPS_VERSION="v3.9.0"
curl -L -o sops https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64
chmod +x sops
sudo mv sops /usr/local/bin/sops

echo "=== Creating SOPS age key directory ==="
mkdir -p ~/.config/sops/age

if [ ! -f ~/.config/sops/age/keys.txt ]; then
  echo "=== Generating age key for SOPS ==="
  age-keygen -o ~/.config/sops/age/keys.txt
else
  echo "=== Age key already exists, skipping ==="
fi

echo "=== Exporting SOPS_AGE_KEY_FILE environment variable ==="
if ! grep -q "SOPS_AGE_KEY_FILE" ~/.bashrc; then
  echo 'export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"' >> ~/.bashrc
fi

echo "=== Installing yq (YAML processor) ==="
sudo wget -q https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
  -O /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq

echo "=== Installing kubectx + kubens ==="
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx || true
sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens

echo "=== Creating SSH directory if missing ==="
mkdir -p ~/.ssh
chmod 700 ~/.ssh

echo "=== Control VM bootstrap complete ==="
echo "Restart your shell or run: source ~/.bashrc"