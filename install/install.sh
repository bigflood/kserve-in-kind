#!/bin/bash

set -eu -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

source vars.sh

./download-commands.sh

KIND_CLUSTER_EXISTS=$("$BIN_DIR/kind" get clusters || true | grep -e '^kserve$')

if [[ "$KIND_CLUSTER_EXISTS" == "" ]]; then
    "$BIN_DIR/kind" create cluster \
        --name kserve \
        --image "kindest/node:v$K8S_VER" \
        --config "$SCRIPT_DIR/files/kind-config.yaml"

    "$BIN_DIR/kind" export kubeconfig --name kserve --kubeconfig "$KUBECONFIG"
fi

echo "install istio .."
"$BIN_DIR/istioctl" install -y -f "$SCRIPT_DIR/files/istio.yaml"

echo "install knative .."

"$BIN_DIR/kubectl" apply --filename https://github.com/knative/serving/releases/download/${KNATIVE_VERSION}/serving-crds.yaml
"$BIN_DIR/kubectl" apply --filename https://github.com/knative/serving/releases/download/${KNATIVE_VERSION}/serving-core.yaml
"$BIN_DIR/kubectl" apply --filename https://github.com/knative/net-istio/releases/download/${KNATIVE_VERSION}/release.yaml

echo "install cert-manager .."

"$BIN_DIR/kubectl" apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.yaml
"$BIN_DIR/kubectl" wait --for=condition=available --timeout=600s deployment/cert-manager-webhook -n cert-manager

echo "install kserve .."

KSERVE_CONFIG=kfserving.yaml
if [ ${KSERVE_VERSION:3:1} -gt 6 ]; then KSERVE_CONFIG=kserve.yaml; fi

# Retry inorder to handle that it may take a minute or so for the TLS assets required for the webhook to function to be provisioned
for i in 1 2 3 4 5 ; do "$BIN_DIR/kubectl" apply -f https://github.com/kserve/kserve/releases/download/${KSERVE_VERSION}/${KSERVE_CONFIG} && break || sleep 15; done
# Install KServe built-in servingruntimes
"$BIN_DIR/kubectl" wait --for=condition=ready pod -l control-plane=kserve-controller-manager -n kserve --timeout=300s
"$BIN_DIR/kubectl" apply -f https://github.com/kserve/kserve/releases/download/${KSERVE_VERSION}/kserve-runtimes.yaml

echo "install kserve addons .."

"$BIN_DIR/kubectl" apply -f https://raw.githubusercontent.com/istio/istio/release-$ISTIO_VERSION_M/samples/addons/prometheus.yaml
"$BIN_DIR/kubectl" apply -f https://raw.githubusercontent.com/istio/istio/release-$ISTIO_VERSION_M/samples/addons/kiali.yaml
"$BIN_DIR/kubectl" apply -f https://raw.githubusercontent.com/istio/istio/release-$ISTIO_VERSION_M/samples/addons/jaeger.yaml
"$BIN_DIR/kubectl" apply -f https://raw.githubusercontent.com/istio/istio/release-$ISTIO_VERSION_M/samples/addons/grafana.yaml

echo "create local registry .."
./create-local-registry.sh
