# 🚀 VMware to Kubernetes Migration Toolkit

> A practical, battle-tested guide and toolset for migrating workloads from VMware vSphere to Kubernetes — built on 10+ years of VMware experience.

## 🎯 Who Is This For?

- VMware administrators moving into cloud-native / DevOps roles
- Teams migrating on-prem VMware workloads to Kubernetes (on-prem or cloud)
- Platform engineers building hybrid VMware + K8s infrastructure

## 🗺️ Migration Phases

```
Phase 1: Assessment     → Inventory VMs, classify workloads, estimate effort
Phase 2: Foundation     → Deploy K8s cluster (on vSphere or cloud)
Phase 3: Containerise   → Dockerise applications (Dockerfile + Helm chart)
Phase 4: Migrate        → Move workloads with zero-downtime strategy
Phase 5: Decommission   → Validate, monitor, power off VMs
```

## 📁 Structure

```
vmware-to-k8s-migration/
├── assessment/              # VM inventory scripts + workload classification
├── terraform/               # vSphere → K8s infrastructure provisioning
├── dockerfiles/             # Sample Dockerfiles for common VM workloads
├── helm-charts/             # Helm charts for migrated applications
├── migration-scripts/       # Automated migration helper scripts
├── runbooks/                # Step-by-step migration runbooks
└── docs/                    # Architecture diagrams + decision guides
```

## ⚡ Quick Assessment

```bash
# Inventory all powered-on VMs in your vCenter
./assessment/inventory-vms.sh --vcenter vcenter.homelab.local --output vm-inventory.csv

# Classify workloads (stateless/stateful/legacy)
./assessment/classify-workloads.py --input vm-inventory.csv --output workload-report.html
```

## 📊 Workload Classification Matrix

| Type | Examples | Migration Effort | Strategy |
|------|---------|-----------------|----------|
| **Stateless Web App** | nginx, Node.js API | Low 🟢 | Containerise → Deployment |
| **Stateful App** | PostgreSQL, MySQL | Medium 🟡 | StatefulSet + PVC |
| **Legacy App** | Old Java .war, COBOL | High 🔴 | Lift-and-shift or rewrite |
| **Scheduled Jobs** | Cron scripts | Low 🟢 | Kubernetes CronJob |
| **Message Queue** | RabbitMQ, Kafka | Medium 🟡 | StatefulSet + Operator |

## 🔗 Related Resources
- [Kubernetes Migration Guide (CNCF)](https://www.cncf.io/blog/)
- [VMware Tanzu Migration Tools](https://tanzu.vmware.com/)
- [DevOps Homelab](https://github.com/jsakilesh/devops-homelab)