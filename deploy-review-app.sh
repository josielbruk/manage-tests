#!/bin/bash
# Usage: ./deploy-review-app.sh <pr_number> <sha>
PR_NUMBER=${1}
SHA=${2}
RESOURCE_GROUP=your-resource-group
ENV_NAME=your-aca-env-name
REGISTRY=ghcr.io/your-org
FRONTEND_IMAGE=$REGISTRY/pr-$PR_NUMBER-app:$SHA
DB_IMAGE=$REGISTRY/pr-$PR_NUMBER-db:$SHA
DB_NAME=reviewapp
DB_USER=reviewuser
DB_PASSWORD=reviewpass

az containerapp create \
  --name frontend-pr-$PR_NUMBER \
  --resource-group $RESOURCE_GROUP \
  --environment $ENV_NAME \
  --image $FRONTEND_IMAGE \
  --env-vars DB_HOST=db-pr-$PR_NUMBER DB_PORT=5432 DB_NAME=$DB_NAME DB_USER=$DB_USER DB_PASSWORD=$DB_PASSWORD

az containerapp create \
  --name db-pr-$PR_NUMBER \
  --resource-group $RESOURCE_GROUP \
  --environment $ENV_NAME \
  --image $DB_IMAGE \
  --env-vars POSTGRES_DB=$DB_NAME POSTGRES_USER=$DB_USER POSTGRES_PASSWORD=$DB_PASSWORD
