# CloudDevOpsProject — iVolve

An end-to-end DevOps platform for the **iVolve** microservices web application,
built as a graduation project in collaboration with **iVolve Technologies**
and the **National Telecommunication Institute (NTI)**.

The project implements the complete software-delivery lifecycle:
containerization → infrastructure as code → configuration management →
Kubernetes orchestration → continuous integration (Jenkins) →
GitOps continuous deployment (ArgoCD).

---

## 1. Application Overview

iVolve is a microservices web application with user authentication and a
DevOps roadmap page. The source code (originally from
[Ibrahim-Adel15/iVolveFinalProject](https://github.com/Ibrahim-Adel15/iVolveFinalProject))
is stored in this repository under `iVolveFinalProject/` (monorepo layout).

| Service           | Technology              | Port | Responsibility                          |
|-------------------|-------------------------|-----:|-----------------------------------------|
| `frontend`        | Node.js / Express / EJS | 3000 | Web UI (auth page + roadmap page)        |
| `auth-service`    | Python / Flask          | 5000 | Signup & login; only service that talks to MySQL |
| `roadmap-service` | Java / Spring Boot      | 8080 | Roadmap data                             |
| `MySQL`           | MySQL 8                 | 3306 | Stores users (`ivolve.users`)            |

---

## 2. Architecture Overview

```text
                           ┌────────────────────────┐
                           │      Users/Browser     │
                           └───────────┬────────────┘
                                       │ HTTP
                                       ▼
                          ┌─────────────────────────┐
                          │  AWS Load Balancer      │
                          │  (NGINX Ingress Ctrl)   │
                          └────────────┬────────────┘
                                       ▼
   ┌────────────────────── Amazon EKS (2 AZs) ──────────────────────┐
   │  frontend ──▶ auth-service ──▶ MySQL (StatefulSet + EBS gp3)   │
   │      └──────▶ roadmap-service     (headless svc, StorageClass) │
   └────────────────────────────────────────────────────────────────┘

   CI/CD PLANE (GitOps):
   Developer ─▶ GitHub ─▶ Jenkins: Build → Trivy Scan → Push ECR →
   Update Manifests → Push Manifests ─▶ ArgoCD watches Git ─▶ syncs EKS
```

### Toolchain & Rationale

| Tool | Responsibility | Why it was chosen |
|------|----------------|-------------------|
| GitHub | Single source of truth | App code, IaC, pipelines, manifests, docs — everything versioned |
| Docker / Compose | Containerization, local testing | Reproducible builds per microservice |
| Terraform | AWS provisioning (Network, Server, EKS, ECR modules) | Versioned, destroyable, reproducible infra; S3 backend + DynamoDB locking |
| Ansible | Jenkins server config + cluster bootstrap | Idempotent, agentless, role-based configuration management |
| Amazon EKS | Orchestration | Self-healing, rolling updates, service discovery, 2-AZ HA |
| Amazon ECR | Container registry | Private, IAM-secured image storage |
| Jenkins | CI | Automated Build/Scan/Push/Update/Push-Manifests pipelines |
| Trivy | Security scanning | Vulnerability visibility inside CI |
| ArgoCD | CD (GitOps) | Cluster continuously converges to Git; drift detection & self-heal |

### Key Design Decisions
- **GitOps split:** Jenkins never runs `kubectl apply`. It only updates Git; ArgoCD performs all deployments. GitHub is the only source of truth.
- **IAM roles over static keys:** Jenkins pushes to ECR via its instance role; no hardcoded AWS credentials.
- **StatefulSet + headless Service + StorageClass (gp3, `WaitForFirstConsumer`)** for MySQL: stable identity, direct pod addressing, AZ-aware EBS volumes.
- **`directory.recurse: true`** in the ArgoCD app because manifests live in `database/` and `microservices/` subfolders.
- **`strategy: Recreate`** on Deployments: guarantees clean rollouts on a small 2-node cluster.
- **Teardown ordering:** add-on Load Balancers are removed (and AWS is waited on) *before* VPC deletion to avoid `DependencyViolation` errors.

---

## 3. Repository Structure

```text
.
├── ansible/                    
│   ├── inventory/aws_ec2.yml   
│   ├── playbook.yml            
│   ├── cluster-bootstrap.yml   
│   ├── cluster-teardown.yml    
│   └── roles/                  
├── argocd/application.yaml     
├── docker-compose.yaml         
├── infrastructure_terraform/  
│   ├── network/                
│   ├── server/                 
│   ├── eks/                    
│   ├── ecr/                    
│   └── backend.tf              
├── iVolveFinalProject/         
├── jenkins/
│   ├── <service>/Jenkinsfile   
│   └── shared-library/vars/    
│                               
├── kubernetes/
│   ├── namespace.yaml  configmap.yaml  secret.yaml  storageclass.yaml  ingress.yaml
│   ├── database/               
│   └── microservices/          
├── screenshots/                
├── setup.sh / teardown.sh      
└── README.md
```

---

## 4. Prerequisites

- AWS account + configured CLI · GitHub account + PAT (`repo` scope)
- Local tools: `terraform`, `ansible`, `docker`, `kubectl`, `helm`, `git`
- AWS Session Manager plugin (for SSM-based Ansible connection):
  ```bash
  curl -O https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb
  sudo dpkg -i session-manager-plugin.deb
  ```

---

## 5. Setup Instructions

### 5.1 — Test the application locally 
```bash
docker compose up --build     # → http://localhost:3000
docker compose down
```

### 5.2 — Provision infrastructure
```bash
cd infrastructure_terraform
terraform init
terraform apply -auto-approve     # VPC, Jenkins EC2, EKS (2 AZs), ECR
```

### 5.3 — Configure the Jenkins server
```bash
cd ../ansible
ansible-playbook -i inventory/aws_ec2.yml playbook.yml
```

### 5.4 — Bootstrap cluster add-ons & GitOps 
```bash
ansible-playbook cluster-bootstrap.yml
# installs NGINX Ingress + ArgoCD, then applies argocd/application.yaml.
# ArgoCD then deploys EVERYTHING in kubernetes/ automatically.
```

### 5.5 — One-time Jenkins UI configuration 
1. **Credential** `github-pat` (Kind: Username with password; your GitHub username + PAT).
2. **Global Pipeline Library**: Name `ivolve-shared`, Default version `main`,
   Repository = this repo, **Script Path `jenkins/shared-library`**.
3. **Three pipeline jobs** (Pipeline from SCM, branch `*/main`), script paths:
   `jenkins/frontend/Jenkinsfile`, `jenkins/auth-service/Jenkinsfile`,
   `jenkins/roadmap-service/Jenkinsfile`.

### 5.6 — Run CI/CD
Click **Build Now** on each job. Jenkins builds → scans (Trivy) → pushes to ECR →
updates the image tag in `kubernetes/` → commits to GitHub → **ArgoCD syncs EKS**.

### 5.7 — Access everything
| What | How |
|------|-----|
| App | `kubectl get svc -n ingress-nginx` → open EXTERNAL-IP/hostname |
| ArgoCD UI | `kubectl get svc argocd-server -n argocd`; password: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" \| base64 -d` |
| Jenkins | EC2 public DNS / ALB, port 8080 |

---

## 6. CI Pipeline (per microservice)

| Stage | What it does |
|-------|--------------|
| Build Image | `docker build` from `iVolveFinalProject/<service>` |
| Scan Image | Trivy (HIGH/CRITICAL report, `--ignore-unfixed`) |
| Push Image | ECR login via IAM role → tag `:<BUILD_NUMBER>` → push |
| Delete Image Locally | Keeps the Jenkins agent clean |
| Update Manifests | Rewrites `image:` in the service's Deployment YAML |
| Push Manifests | Commits `[skip ci] Deploy <svc> build N` to GitHub |

All logic lives in the **shared library** (`jenkins/shared-library/vars/*.groovy`),
so the three Jenkinsfiles stay thin and identical in structure.

---

## 7. Kubernetes Resources

| File | Kind | Purpose |
|------|------|---------|
| `namespace.yaml` | Namespace | Isolated `ivolve` environment |
| `configmap.yaml` | ConfigMap | Non-sensitive config (DB host/port/name, service URLs) |
| `secret.yaml` | Secret | DB credentials |
| `storageclass.yaml` | StorageClass | gp3 EBS, `WaitForFirstConsumer` |
| `database/mysql-statefulset.yaml` | StatefulSet | MySQL with persistent EBS volume |
| `database/mysql-headless-svc.yaml` | Service (headless) | Stable pod DNS, no load-balancing |
| `microservices/*-deployment.yaml` | Deployment ×3 | Stateless apps, `Recreate` strategy |
| `microservices/*-svc.yaml` | Service ×3 | Internal discovery |
| `ingress.yaml` | Ingress | External access to `frontend` via NGINX |

---

## 8. Deliverables Map

| # | Requirement | Location |
|---|-------------|----------|
| 1 | GitHub repository | this repo |
| 2 | docker-compose | `docker-compose.yaml` |
| 3 | Terraform modules + S3 backend | `infrastructure_terraform/` |
| 4 | Ansible roles + dynamic inventory | `ansible/` |
| 5 | Kubernetes YAMLs | `kubernetes/` |
| 6 | Jenkins pipelines + shared library | `jenkins/` |
| 7 | ArgoCD Application | `argocd/application.yaml` |
| 8 | Documentation | this README + `screenshots/` (+ per-directory READMEs, in progress) |

---

## 9. Teardown & Cost Control

```bash
./teardown.sh
# = ansible-playbook cluster-teardown.yml   (release LBs, wait for AWS cleanup)
# + terraform destroy -auto-approve
```
Intentionally kept (near-zero cost): ECR images, S3 state, DynamoDB lock table.

---

## 10. Future Improvements

- GitHub webhook → auto-trigger pipelines on push.
- Jenkins Configuration-as-Code (JCasC) for zero-manual Jenkins setup.
- HTTPS + custom domain (cert-manager + Route53).
- Helm charts / Kustomize overlays for dev–staging–prod environments.
- HPA + Karpenter for elastic scaling; Argo Rollouts for canary deployments.
- Sealed Secrets / External Secrets; Kyverno policy gates; network policies.
- Observability stack: Prometheus + Grafana, Loki logs, alerting.

- Velero backups of MySQL/EBS to S3 with restore drills.

---

*Built by **Anis Emad** — DevOps graduation project, NTI × iVolve Technologies.*                                                      