#!/bin/bash

set -eu -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

source ../install/vars.sh

echo "create isvc.."

"$KUBECTL_CLI" apply -f isvc-iris.yaml
"$KUBECTL_CLI" wait --for=condition=Ready --timeout=60s -n lab isvc/sklearn-iris

poetry run python infer-req.py --delay 0.1 --namespace lab
