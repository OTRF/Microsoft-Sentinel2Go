#!/bin/bash

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# Reference:
# https://docs.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest#az-rest
# https://github.com/Azure/Azure-Security-Center/tree/master/Powershell%20scripts/Security%20Event%20collection%20tier
# https://medium.com/@mauridb/calling-azure-rest-api-via-curl-eb10a06127
# https://oncletom.io/2016/pipelining-http/
# https://starkandwayne.com/blog/bash-for-loop-over-json-array-using-jq/
# https://cameronnokes.com/blog/working-with-json-in-bash-using-jq/

set -e

script_name=$0

usage(){
  echo "Invalid option: -$OPTARG"
  echo "Usage: ${script_name} -r <Resource group name>"
  echo "                      -w <Log Analytics Workspace Name>"
  exit 1
}

while getopts r:w:h opt; do
    case "$opt" in
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
    SYSTEM_KERNEL="$(uname -s)"
    for row in $(curl -sS https://raw.githubusercontent.com/OTRF/Microsoft-Sentinel2Go/master/microsoft-sentinel/analytic-rules/allAnalyticRules.json | jq -r '.[] | @base64'); do
        return_code=$?
        # Generating GUID for analytic rule Id
        if [ "$SYSTEM_KERNEL" == "Linux" ]; then
            name=$(cat /proc/sys/kernel/random/uuid)
        elif [ "$SYSTEM_KERNEL" == "Darwin" ]; then
            name=$(uuidgen)
        fi
        # Getting analytic rule name
        ruleName=$(echo ${row} | base64 -d | jq -r ${1}.properties.displayName)
        # Posting analytic rule to Azure Sentinel's workspace
        echo -e  "\n[+] Analytic Rule: $ruleName"
        echo ${row} | base64 -d | jq -r ${1} | az rest -m put -u "https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.OperationalInsights/workspaces/${WORKSPACE_NAME}/providers/Microsoft.SecurityInsights/alertRules/${name}?api-version=2019-01-01-preview" --body @-  --verbose || return_code=$?
        # Handling error
        if [ "$return_code" != "0" ] && [ "$return_code" ]; then
            RED='\033[0;31m'
            NC='\033[0m'
            echo -e "${RED}[!] Creation of analytic rule failed.."
            echo ${row} | base64 -d | jq -Mr ${1}
            echo -e "${NC}"
        fi
        sleep 1
    done
fi
