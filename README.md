# manage-tests

## Review App Architecture & CI/CD Workflow

This project uses GitHub Actions and Azure DevOps to build, push, and attest Docker images for ephemeral Review Apps. Each pull request (PR) triggers a build and deploys a unique environment using Azure Container Apps.

### How It Works

### CI/CD Workflow & Pipeline Files

#### GitHub Actions Workflows (`.github/workflows/`)

- **review-apps-build.yaml**
  - Builds Docker images for frontend and database on PR open/update.
  - Tags images as `pr-<number>-app:<sha>` and `pr-<number>-db:<sha>`.
  - Pushes images to GitHub Container Registry (`ghcr.io`).
  - Attests provenance for supply chain security.
  - Purpose: Build and publish Docker images for ephemeral Review Apps.

- **review-apps-publish.yaml**
  - Similar to `review-apps-build.yaml`, used for building and publishing images for PR environments.
  - Purpose: Build and publish Docker images for review apps (legacy/alternate workflow).

- **review-app-build-publish.yaml**
  - Combined build and publish workflow for review app images.
  - Purpose: Build and publish Docker images for PR environments (alternate workflow).

- **azure-pipeline-pr.yml**
  - Triggers Azure DevOps pipeline on PR open/update.
  - Outputs PR number and Docker image tag.
  - Purpose: Integrates GitHub PR events with Azure DevOps for review app deployment.

#### Azure DevOps Pipelines (`.azuredevops/`)

- **review-apps-build-deploy-pipeline.yml**
  - Builds, pushes, deploys, and cleans up ephemeral Review App environments for feature branches and PRs.
  - Uses PR number and SHA for image tagging and environment management.
  - Deploys the database (Postgres) container app first, retrieves its FQDN, and injects it as the `DB_HOST` environment variable for the frontend container app. This ensures the frontend can connect to the database in Azure Container Apps.
  - Purpose: Full build/deploy/cleanup pipeline for review apps.

- **review-apps-trigger-pipeline.yaml**
  - Triggered by GitHub PR events (via workflow).
  - Receives PR number, SHA, and Docker tag to deploy/manage ephemeral environments for feature review/testing.
  - Purpose: PR event-driven deployment pipeline for review apps.

### Usage

1. **Fork/Clone the repository.**
2. **Configure GitHub Secrets:**
   - `GITHUB_TOKEN`: (default, provided by GitHub Actions)
   - `AZURE_DEVOPS_PROJECT_URL`: URL to your Azure DevOps project.
   - `AZURE_DEVOPS_TOKEN`: Personal Access Token for Azure DevOps.
3. **Configure Azure DevOps Pipelines:**
   - Import `.azuredevops/review-apps-build-deploy-pipeline.yml` and `.azuredevops/review-apps-trigger-pipeline.yaml` into your Azure DevOps project.
   - Ensure the pipelines are named clearly for review app usage.
   - Set up a service connection for Azure CLI tasks.
4. **Set Required Environment Variables:**
   - In Azure DevOps or GitHub Actions, set:
     - `REGISTRY`: e.g., `ghcr.io/<your-org>`
     - `APP_IMAGE_NAME`: e.g., `pr-<number>-app`
     - `DB_IMAGE_NAME`: e.g., `pr-<number>-db`
     - `DB_NAME`, `DB_USER`, `DB_PASSWORD` (for database container)
     - `AZURE_RESOURCE_GROUP`, `AZURE_CONTAINERAPPS_ENV` (for deployment)
5. **Open a Pull Request:**
   - The workflow will build and push Docker images named and tagged for the PR:
     - Frontend: `pr-<number>-app:<sha>`
     - Database: `pr-<number>-db:<sha>`
   - Azure DevOps pipeline will:
     - Deploy the database (Postgres) container app first.
     - Retrieve the FQDN of the database container app.
     - Deploy the frontend container app, passing the FQDN as `DB_HOST` so the frontend can connect to the database.
   - On PR close/merge, the environment is automatically cleaned up.

### Local Development

- Use `apps/docker-compose.yml` for local testing:
  ```bash
  cd apps
  cp database/.env.db.template database/.env.db
  cp frontend/.env.frontend.template frontend/.env.frontend
  docker-compose up --build
  ```

### Manual Deployment & Teardown

- Use provided scripts:
  - `deploy-review-app.sh <branch>`: Deploys review app for a branch.
  - `teardown-review-app.sh <branch>`: Removes review app environment.

### Required Secrets & Variables

| Name                      | Where           | Purpose                                 |
|---------------------------|-----------------|-----------------------------------------|
| GITHUB_TOKEN              | GitHub Actions  | Auth for pushing images to GHCR          |
| AZURE_DEVOPS_PROJECT_URL  | GitHub Actions  | URL to Azure DevOps project              |
| AZURE_DEVOPS_TOKEN        | GitHub Actions  | Auth for triggering Azure pipeline        |
| AZURE_RESOURCE_GROUP      | Azure DevOps    | Resource group for Container Apps        |
| AZURE_CONTAINERAPPS_ENV   | Azure DevOps    | Container Apps environment name          |
| DB_NAME, DB_USER, DB_PASSWORD | Both        | Database configuration                   |

### Notes

- Ensure your Azure DevOps service connection has permissions for Container Apps.
- Update image names, registry, and resource group as needed for your organization.
- The workflow and pipeline are designed for ephemeral environments per PR for safe feature testing and review.
- In Azure Container Apps, containers do not get automatic DNS hostnames. The pipeline now retrieves the database container app's FQDN and injects it as `DB_HOST` for the frontend, ensuring reliable connectivity.

---

For further customization or troubleshooting, see the comments in workflow and pipeline YAML files.
