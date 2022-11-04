# kserve-in-kind

## Prerequisites

- linux (amd64)
- curl
- docker
- python-poetry

## Install kind cluster and kserve

```
./install/install.sh
```

## Inference service and predictions

```
./lab/install.sh
./start-isvc.sh
```

## Show kiali dashboard

```
./install/dashboard-kiali.sh
```

## Show jaeger dashboard

```
./install/dashboard-jaeger.sh
```
