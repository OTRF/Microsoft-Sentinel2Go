#!/bin/bash

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

usage(){
    echo " "
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -i         Log Analytics workspace id"
    echo "   -k         Log Analytics workspace shared key"
    echo "   -u         Local user to update files ownership"
    echo "   -a         Azure environment name"
    echo "   -c         EventHub Connection String Primary"
    echo "   -e         EventHub name"
    echo
    echo "Examples:"
    echo " $0 -i <Log Analytics workspace id> -c <Endpoint=sb://xxxxx> -e <Event hub name> -k <Log Analytics workspace shared key> -u wardog -m"
    echo " "
    exit 1
}

# ************ Command Options **********************
while getopts :i:k:u:c:e:h option
do
    case "${option}"
    in
        i) WORKSPACE_ID=$OPTARG;;
        k) WORKSPACE_KEY=$OPTARG;;
        u) LOCAL_USER=$OPTARG;;
        a) AZURE_ENVIRONMENT=$OPTARG;;
        c) EVENTHUB_CONNECTIONSTRING=$OPTARG;;
        e) EVENTHUB_NAME=$OPTARG;;
        h) usage;;
        \?) usage;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done

if ((OPTIND == 1))
then
    echo "No options specified"
    usage
fi

if [ -z "$WORKSPACE_ID" ] || [ -z $WORKSPACE_KEY ] || [ -z "$LOCAL_USER" ]; then
    echo "[!] Make sure you provide values for the Workspace ID (-i) and local user (-u)"
    usage
else
    # Removing old docker
    if [ -x "$(command -v docker)" ]; then
        echo "Removing docker.."
        apt-get remove -y docker docker-engine docker.io containerd runc
    fi

    # Installing latest Docker
    echo "Installing docker via convenience script.."
    curl -fsSL https://get.docker.com -o get-docker.sh
    chmod +x get-docker.sh
    ./get-docker.sh

    # Starting Docker service
    while true; do
        if (systemctl --quiet is-active docker.service); then
            echo "Docker is running."
            docker -v
            break
        else
            echo "Docker is not running. Attempting to start it.."
            systemctl enable docker.service
            systemctl start docker.service
            sleep 2
        fi
    done

    echo "creating local logstash folders"
    mkdir -p /opt/logstash/{scripts,pipeline,config,datasets}

    echo "Downloading logstash files locally to be mounted to docker container"
    wget -O /opt/logstash/scripts/logstash-entrypoint.sh https://raw.githubusercontent.com/shawnadrockleonard/Azure-Sentinel2Go/shawns/dev/grocery-list/custom-log-pipeline/logstash/scripts/logstash-entrypoint.sh
    
    if [[ -n $AZURE_ENVIRONMENT ]] && [[ "$AZURE_ENVIRONMENT" == "azureusgovernment" ]]; then
        wget -O /opt/logstash/pipeline/loganalytics-output.conf https://raw.githubusercontent.com/shawnadrockleonard/Azure-Sentinel2Go/shawns/dev/grocery-list/custom-log-pipeline/logstash/pipeline/loganalytics-output-usgov.conf
    else
        wget -O /opt/logstash/pipeline/loganalytics-output.conf https://raw.githubusercontent.com/shawnadrockleonard/Azure-Sentinel2Go/shawns/dev/grocery-list/custom-log-pipeline/logstash/pipeline/loganalytics-output.conf
    fi

    wget -O /opt/logstash/config/logstash.yml https://raw.githubusercontent.com/shawnadrockleonard/Azure-Sentinel2Go/shawns/dev/grocery-list/custom-log-pipeline/logstash/config/logstash.yml
    wget -O /opt/logstash/docker-compose.yml https://raw.githubusercontent.com/shawnadrockleonard/Azure-Sentinel2Go/shawns/dev/grocery-list/custom-log-pipeline/logstash/docker-compose.yml
    wget -O /opt/logstash/Dockerfile https://raw.githubusercontent.com/shawnadrockleonard/Azure-Sentinel2Go/shawns/dev/grocery-list/custom-log-pipeline/logstash/Dockerfile

    if [[ $EVENTHUB_CONNECTIONSTRING ]] && [[ $EVENTHUB_NAME ]]; then
        wget -O /opt/logstash/pipeline/eventhub-input.conf https://raw.githubusercontent.com/shawnadrockleonard/Azure-Sentinel2Go/shawns/dev/grocery-list/custom-log-pipeline/logstash/pipeline/eventhub-input.conf
    fi

    chown -R $LOCAL_USER:$LOCAL_USER /opt/logstash/*
    chmod +x /opt/logstash/scripts/logstash-entrypoint.sh

    # Build Docker Image
    docker build /opt/logstash/ -t docker-logstash
    
    export WORKSPACE_ID="$WORKSPACE_ID"
    export WORKSPACE_KEY="$WORKSPACE_KEY"

    if [[ $EVENTHUB_CONNECTIONSTRING ]] && [[ $EVENTHUB_NAME ]]; then
        export EVENTHUB_CONNECTIONSTRING="${EVENTHUB_CONNECTIONSTRING};EntityPath=${EVENTHUB_NAME}"

        docker run --restart always --entrypoint /opt/logstash/scripts/logstash-entrypoint.sh \
            -v /opt/logstash/pipeline:/usr/share/logstash/pipeline \
            -v /opt/logstash/scripts:/usr/share/logstash/scripts \
            -v /opt/logstash/config/logstash.yml:/usr/share/logstash/config/logstash.yml \
            -v /opt/logstash/datasets:/usr/share/logstash/datasets \
            -e xpack.monitoring.enabled=false \
            -e WORKSPACE_ID=${WORKSPACE_ID} \
            -e EVENTHUB_CONNECTIONSTRING=${EVENTHUB_CONNECTIONSTRING} \
            -e WORKSPACE_KEY=${WORKSPACE_KEY} \
            -e EVENTHUB_NAME=${EVENTHUB_NAME} \
            --name logstash -d docker-logstash
    else
        docker run --restart always --entrypoint /opt/logstash/scripts/logstash-entrypoint.sh \
            -v /opt/logstash/pipeline:/usr/share/logstash/pipeline \
            -v /opt/logstash/scripts:/usr/share/logstash/scripts \
            -v /opt/logstash/config/logstash.yml:/usr/share/logstash/config/logstash.yml \
            -v /opt/logstash/datasets:/usr/share/logstash/datasets \
            -e xpack.monitoring.enabled=false \
            -e WORKSPACE_ID=${WORKSPACE_ID} \
            -e WORKSPACE_KEY=${WORKSPACE_KEY} \
            --name logstash -d docker-logstash
    fi
fi