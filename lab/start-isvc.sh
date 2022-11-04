#!/bin/bash

set -eu -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

source ../install/vars.sh

echo "create isvc.."

"$BIN_DIR/kubectl" apply -f sklearn-iris-isvc.yaml
"$BIN_DIR/kubectl" wait --for=condition=Ready --timeout=60s -n lab isvc/sklearn-iris

poetry run python infer-req.py --delay 0.1 --namespace lab
