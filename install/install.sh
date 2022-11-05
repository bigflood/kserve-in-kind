#!/bin/bash

set -eu -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

source vars.sh

./download-commands.sh

KIND_CLUSTER_EXISTS=$("$KIND_CLI" get clusters || true | grep -e '^kserve$')

if [[ "$KIND_CLUSTER_EXISTS" == "" ]]; then
    "$KIND_CLI" create cluster \
        --name kserve \
        --image "kindest/node:v$K8S_VER" \
        --config "$SCRIPT_DIR/files/kind-config.yaml"

    "$KIND_CLI" export kubeconfig --name kserve --kubeconfig "$KUBECONFIG"
fi

echo "install istio .."
"$ISTIO_CLI" install -y -f "$SCRIPT_DIR/files/istio.yaml"

echo "install knative .."

"$KUBECTL_CLI" apply --filename https://github.com/knative/serving/releases/download/${KNATIVE_VERSION}/serving-crds.yaml
"$KUBECTL_CLI" apply --filename https://github.com/knative/serving/releases/download/${KNATIVE_VERSION}/serving-core.yaml
"$KUBECTL_CLI" apply --filename https://github.com/knative/net-istio/releases/download/${KNATIVE_VERSION}/release.yaml

echo "install cert-manager .."

"$KUBECTL_CLI" apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.yaml
"$KUBECTL_CLI" wait --for=condition=available --timeout=600s deployment/cert-manager-webhook -n cert-manager

echo "install kserve .."

# Retry inorder to handle that it may take a minute or so for the TLS assets required for the webhook to function to be provisioned
for i in 1 2 3 4 5 ; do "$KUBECTL_CLI" apply -f https://github.com/kserve/kserve/releases/download/${KSERVE_VERSION}/kserve.yaml && break || sleep 15; done
# Install KServe built-in servingruntimes
"$KUBECTL_CLI" wait --for=condition=ready pod -l control-plane=kserve-controller-manager -n kserve --timeout=300s
"$KUBECTL_CLI" apply -f https://github.com/kserve/kserve/releases/download/${KSERVE_VERSION}/kserve-runtimes.yaml

# echo "install kserve addons .."

"$KUBECTL_CLI" apply -f https://raw.githubusercontent.com/istio/istio/release-$ISTIO_VERSION_M/samples/addons/prometheus.yaml
"$KUBECTL_CLI" apply -f https://raw.githubusercontent.com/istio/istio/release-$ISTIO_VERSION_M/samples/addons/kiali.yaml
"$KUBECTL_CLI" apply -f https://raw.githubusercontent.com/istio/istio/release-$ISTIO_VERSION_M/samples/addons/jaeger.yaml
"$KUBECTL_CLI" apply -f https://raw.githubusercontent.com/istio/istio/release-$ISTIO_VERSION_M/samples/addons/grafana.yaml

echo "create local registry .."
./create-local-registry.sh
