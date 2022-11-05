#!/bin/bash

set -eu -o pipefail
INSTALL_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export KIND_VER=0.17.0
export K8S_VER=1.24.7
export ISTIO_VERSION_M=1.14
export ISTIO_VERSION=$ISTIO_VERSION_M.0
export KNATIVE_VERSION=knative-v1.4.0
export KSERVE_VERSION=v0.9.0
export CERT_MANAGER_VERSION=v1.3.0
export KUBECONFIG="$INSTALL_DIR/../.kubeconfig"
export BIN_DIR="$INSTALL_DIR/bin"

export KIND_CLI="$BIN_DIR/kind-$KIND_VER"
export ISTIO_CLI="$BIN_DIR/istio-$ISTIO_VERSION_M"
export KUBECTL_CLI="$BIN_DIR/kubectl-$K8S_VER"
