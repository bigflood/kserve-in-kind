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
./lab/start-isvc.sh
```

## dashboards

```
./install/dashboard-kiali.sh
```

```
./install/dashboard-jaeger.sh
```

```
./install/dashboard-grafana.sh
```
