#!/bin/bash

set -eu -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

source ../install/vars.sh

echo "create isvc.."

"$KUBECTL_CLI" apply -f isvc-tf.yaml
# "$KUBECTL_CLI" wait --for=condition=Ready --timeout=60s -n lab isvc/flowers-sample

poetry run python infer-req.py \
  --delay 0.1 \
  --namespace lab \
  --name flowers-sample \
  --model flowers-sample \
  --input-file flowers-sample-input.json \
  --log-interval 5
