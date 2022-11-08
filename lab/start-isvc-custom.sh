#!/bin/bash

set -eu -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

VER="0.1"

source ../install/vars.sh

docker build --platform linux/amd64 \
    -t localhost:5001/custom_transformer:$VER \
    -f custom_transformer.Dockerfile \
    .

docker push localhost:5001/custom_transformer:$VER


docker build --platform linux/amd64 \
    -t localhost:5001/custom_model:$VER \
    -f custom_model.Dockerfile \
    .

docker push localhost:5001/custom_model:$VER

echo "create isvc.."

"$KUBECTL_CLI" apply -f isvc-custom-model.yaml
"$KUBECTL_CLI" wait --for=condition=Ready --timeout=60s -n lab isvc/custom-model

poetry run python infer-req.py --delay 1.0 --namespace lab
