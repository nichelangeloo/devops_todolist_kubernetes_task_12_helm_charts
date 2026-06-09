#!/bin/bash
set -e

echo "Deploying charts"
helm upgrade --install todoapp ./.infrastructure/helm-charts/todoapp \
  --values ./.infrastructure/helm-charts/todoapp/values.yaml \
  --namespace todoapp \
  --create-namespace \
  --wait

echo "All charts deployed without errors"