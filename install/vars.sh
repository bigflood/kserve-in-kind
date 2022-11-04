#!/bin/bash

set -eu -o pipefail
INSTALL_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export K8S_VER=1.22.9
export ISTIO_VERSION_M=1.11
export ISTIO_VERSION=$ISTIO_VERSION_M.8
export KNATIVE_VERSION=knative-v1.0.0
export KSERVE_VERSION=v0.8.0
export CERT_MANAGER_VERSION=v1.3.0
export KUBECONFIG="$INSTALL_DIR/../.kubeconfig"
export BIN_DIR="$INSTALL_DIR/bin"
