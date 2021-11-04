#!/bin/bash

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# Reference:
# https://docs.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest#az-rest
# https://github.com/Azure/Azure-Security-Center/tree/master/Powershell%20scripts/Security%20Event%20collection%20tier
# https://medium.com/@mauridb/calling-azure-rest-api-via-curl-eb10a06127

set -e

script_name=$0

usage(){
  echo "Invalid option: -$OPTARG"
  echo "Usage: ${script_name} -s <Subscription Id>"
  echo "                      -r <Resource group name>"
  echo "                      -w <Log Analytics Workspace Name>"
  exit 1
}

while getopts s:r:w:h opt; do
    case "$opt" in
        s)  SUBSCRIPTION_ID=$OPTARG;;
        r)  RESOURCE_GROUP_NAME=$OPTARG;;
        w)  WORKSPACE_NAME=$OPTARG;;
        h) #Show help
            usage
            exit 2
            ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

if [ -z "$RESOURCE_GROUP_NAME" ] || [ -z "$WORKSPACE_NAME" ]; then
    usage
else
    if [ "$SUBSCRIPTION_ID" ]; then
        az rest -m get -u "https://management.azure.com/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.OperationalInsights/workspaces/${WORKSPACE_NAME}/providers/Microsoft.SecurityInsights/alertRules?api-version=2019-01-01-preview"  --verbose
    else
        az rest -m get -u "https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.OperationalInsights/workspaces/${WORKSPACE_NAME}/providers/Microsoft.SecurityInsights/alertRules?api-version=2019-01-01-preview"  --verbose
    fi
fi
