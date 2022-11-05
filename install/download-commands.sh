#!/bin/bash

set -eu -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

source vars.sh

function download_bin() {
    URL="$1"
    FILE="$2"
    if [ ! -f "$FILE" ] ; then
        echo "download $URL"
        curl -Lo "$FILE" "$URL"
        chmod +x "$FILE"
    fi
}

function download_tgz_bin() {
    URL="$1"
    FILE="$2"
    CLI_FILE="$3"
    if [ ! -f "$CLI_FILE" ] ; then
        echo "download $URL"
        curl -Lo "$FILE.tgz" "$URL"
        tar xvf "$FILE.tgz" "$FILE"
        rm "$FILE.tgz"
        mv "$FILE" "$CLI_FILE"
    fi
}

ARCH=$(uname -m | sed -e 's/x86_64/amd64/')
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
OS2=$(echo "$OS" | sed -e 's/darwin/osx/')

mkdir -p "$BIN_DIR"
cd "$BIN_DIR"

# NOTE: istio is not arm compatiable.
download_bin "https://kind.sigs.k8s.io/dl/v$KIND_VER/kind-$OS-amd64" "$KIND_CLI"

download_tgz_bin "https://github.com/istio/istio/releases/download/$ISTIO_VERSION/istioctl-$ISTIO_VERSION-$OS2-$ARCH.tar.gz" "istioctl" "$ISTIO_CLI"
download_bin "https://dl.k8s.io/release/v$K8S_VER/bin/$OS/$ARCH/kubectl" "$KUBECTL_CLI"
