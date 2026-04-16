# standard-ci-cd
"Cloud Native" Push (Standard CI/CD)  

## Project 1: The "Cloud Native" Push (Standard CI/CD)

**Theme:** Full Automation, Security-First, and High Availability.

**Focus:** Infrastructure as Code (Terraform) and active deployment via GitHub Actions.

### The Stack

- **App:** Python (Flask/FastAPI) + PostgreSQL.
- **Infrastructure:** AWS (EKS, VPC, Multi-AZ, ASG) via **Terraform**.
- **CI/CD:** GitHub Actions (Pushing directly to EKS).
- **Observability:** Prometheus, Grafana, and CloudWatch Logs.

### Requirements & Stages

| **Stage** | **Domain** | **Requirement** |
| --- | --- | --- |
| **1** | **App & Database** | Build a Python API that performs CRUD operations on a PostgreSQL DB. Database credentials must be handled via environment variables. |
| **2** | **Containerization** | Dockerize the app using a **multi-stage build** for optimization. Create a `docker-compose.yml` for local development. |
| **3** | **Infrastructure** | Write Terraform code for a VPC with 3 Private Subnets (Multi-AZ), a NAT Gateway, and an EKS Cluster with a Managed Node Group (Auto-scaling). |
| **4** | **CI Pipeline** | Create a GitHub Action that triggers on `pull_request`. It must run **Pytest**, **SonarQube** (for code smells/bugs), and **Snyk** (for vulnerability scanning). |
| **5** | **CD Pipeline** | Upon merge to `main`, the Action builds the image, pushes to **Amazon ECR**, and uses `kubectl set image` to update the EKS deployment. |
| **6** | **Monitoring** | Deploy a Prometheus stack to EKS. Configure a **Grafana Dashboard** and an AlertManager rule to notify via Slack if a node goes down. |
