#!/bin/bash
set -e

echo "Deploying charts"
helm dependency build ./.infrastructure/helm-charts/todoapp/Chart.yaml

helm upgrade --install todoapp ./.infrastructure/helm-chart/todoapp \
  --values ./.infrastructure/helm-chart/todoapp/values.yaml \
  --namespace todoapp \
  --create-namespace \
  --wait

echo "All charts deployed without errors"