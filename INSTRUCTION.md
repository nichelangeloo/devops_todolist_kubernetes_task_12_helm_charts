# Deployment Instructions

## Prerequisites

- [`kind`](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) installed
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/) installed
- [`helm`](https://helm.sh/docs/intro/install/) v3 installed

---

## 1. Create a kind cluster

```bash
kind create cluster --config .infrastructure/app/cluster.yml
```

---

## 2. Deploy the charts

From the root of the repository, run:

```bash
bash bootstrap.sh
```

This will:
- Deploy the `mysql` chart into the `mysql` namespace
- Deploy the `todoapp` chart into the `todoapp` namespace
- Wait for all resources to become ready before proceeding

---

## 3. Validate the deployment

### Check all resources across namespaces

```bash
kubectl get all,cm,secret,ing -A
```

### Verify MySQL StatefulSet is ready

```bash
kubectl rollout status statefulset/mysql -n mysql
```

Expected: `statefulset rolling update complete 2 pods at revision mysql-...`

### Verify todoapp Deployment is ready

```bash
kubectl rollout status deployment/todoapp-deployment -n todoapp
```

Expected: `deployment "todoapp-deployment" successfully rolled out`

### Verify HPA is active

```bash
kubectl get hpa -n todoapp
```

Expected: `MINPODS` = 2, `MAXPODS` = 5 with CPU and Memory targets visible.

### Verify secrets are correctly base64-encoded

```bash
kubectl get secret todoapp-secret -n todoapp -o jsonpath='{.data}' | python3 -m json.tool
```

Decode a specific key to confirm the value is correct:

```bash
kubectl get secret todoapp-secret -n todoapp \
  -o jsonpath='{.data.SECRET_KEY}' | base64 --decode
```

### Verify the ingress is created

```bash
kubectl get ingress -n todoapp
```

### Verify mysql connectivity from todoapp pod

```bash
kubectl exec -it deploy/todoapp-deployment -n todoapp -- \
  python3 -c "import os; print(os.environ.get('DB_HOST'))"
```

Expected: `mysql-0.mysql.mysql.svc.cluster.local`

---

## 4. Cleanup

```bash
helm uninstall todoapp -n todoapp
helm uninstall mysql -n mysql
kind delete cluster --name <YOURCLUSTERNAME>
```