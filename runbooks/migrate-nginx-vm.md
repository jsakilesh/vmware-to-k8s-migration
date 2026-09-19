# Runbook: Migrate nginx VM to Kubernetes

**Estimated Time:** 2–4 hours  
**Risk:** Low (stateless workload)  
**Owner:** @jsakilesh  

---

## Pre-Migration Checklist

- [ ] VM inventory completed (`./assessment/inventory-vms.sh`)
- [ ] Application is stateless (no local disk state)
- [ ] Application configs externalised to files (not hardcoded)
- [ ] Docker image built and scanned with Trivy (0 CRITICAL)
- [ ] Helm chart tested in `staging` namespace
- [ ] DNS TTL reduced to 60s (for fast cutover)
- [ ] Rollback plan documented and tested

---

## Step 1 — Build & Scan Docker Image

```bash
# Build image
docker build -t ghcr.io/jsakilesh/nginx-app:v1.0.0 .

# Scan for vulnerabilities
trivy image --severity CRITICAL,HIGH ghcr.io/jsakilesh/nginx-app:v1.0.0

# Sign image (supply chain security)
cosign sign ghcr.io/jsakilesh/nginx-app:v1.0.0

# Push to registry
docker push ghcr.io/jsakilesh/nginx-app:v1.0.0
```

## Step 2 — Deploy to Staging

```bash
helm upgrade --install nginx-app ./helm-charts/nginx-app \
  --namespace staging \
  --create-namespace \
  --set image.tag=v1.0.0 \
  --wait --timeout 5m

# Smoke test
kubectl run test --image=curlimages/curl --rm -it --restart=Never -- \
  curl -s http://nginx-app.staging.svc.cluster.local/health
```

## Step 3 — Traffic Cutover (Zero Downtime)

```bash
# Option A: Update DNS record to point to K8s ingress IP
# Option B: Use weighted routing (if using Istio or AWS ALB)

# Verify traffic is flowing to K8s
kubectl logs -l app=nginx-app -n production --tail=50 -f
```

## Step 4 — Monitor for 24 Hours

```bash
# Watch error rate
watch kubectl top pods -n production

# Check Prometheus alerts
kubectl port-forward svc/prometheus-operated 9090 -n monitoring
```

## Step 5 — Decommission VMware VM

```bash
# Take final snapshot before decommission
govc snapshot.create -vm "nginx-vm" "pre-decommission-$(date +%Y%m%d)"

# Power off VM (after 7-day observation window)
govc vm.power -off nginx-vm

# Delete VM (after 30-day retention)
# govc vm.destroy nginx-vm
```

## Rollback Procedure

```bash
# Immediate rollback: point DNS back to VM IP
# Takes effect after DNS TTL (60s)

# Or scale down K8s deployment and re-enable VM
kubectl scale deployment nginx-app --replicas=0 -n production
govc vm.power -on nginx-vm
```