# manage-tests

## Review App Architecture & CI/CD Workflow

This project uses GitHub Actions and Azure DevOps to build, push, and attest Docker images for ephemeral Review Apps. Each pull request (PR) triggers a build and deploys a unique environment using Azure Container Apps.

### How It Works

### Pipeline Files

- **GitHub Actions Workflow** (`.github/workflows/review-apps-publish.yaml`):
  - Runs on PR open and updates.
  - Builds Docker images named and tagged as `pr-<number>-app:<sha>` for the frontend and `pr-<number>-db:<sha>` for the database.
  - Pushes images to GitHub Container Registry (`ghcr.io`).
  - Generates artifact attestation for provenance.
  - Outputs PR number and Docker image tag.
  - Purpose: Build and publish Docker images for ephemeral Review Apps triggered by PRs.

- **Azure DevOps Build & Deploy Pipeline** (`.azuredevops/azure-pipelines.yml`):
  - Purpose: Build, push, deploy, and clean up ephemeral Review App environments for feature branches and PRs.

- **Azure DevOps Trigger Pipeline** (`.azuredevops/review-apps-trigger-pipeline.yaml`):
  - Purpose: Triggered by GitHub PR events, receives PR number, SHA, and Docker tag to deploy and manage ephemeral environments for feature review and testing.

### Usage

1. **Fork/Clone the repository.**
2. **Configure GitHub Secrets:**
   - `GITHUB_TOKEN`: (default, provided by GitHub Actions)
   - `AZURE_DEVOPS_PROJECT_URL`: URL to your Azure DevOps project.
   - `AZURE_DEVOPS_TOKEN`: Personal Access Token for Azure DevOps.
3. **Configure Azure DevOps Pipelines:**
   - Import `.azuredevops/azure-pipelines.yml` and `.azuredevops/review-apps-trigger-pipeline.yaml` into your Azure DevOps project.
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
   - Azure DevOps pipeline will deploy containers for the PR environment using these images.
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

---

For further customization or troubleshooting, see the comments in workflow and pipeline YAML files.