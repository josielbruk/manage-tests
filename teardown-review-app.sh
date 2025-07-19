#!/bin/bash
# Usage: ./teardown-review-app.sh <pr_number>
PR_NUMBER=${1}
RESOURCE_GROUP=your-resource-group
az containerapp delete --name frontend-pr-$PR_NUMBER --resource-group $RESOURCE_GROUP --yes
az containerapp delete --name db-pr-$PR_NUMBER --resource-group $RESOURCE_GROUP --yes
