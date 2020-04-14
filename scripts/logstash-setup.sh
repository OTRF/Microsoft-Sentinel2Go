#!/bin/bash

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

usage(){
    echo " "
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -i         Log Analytics workspace id"
    echo "   -c         EventHub Connection String Primary"
    echo "   -e         EventHub name"
    echo "   -k         Log Analytics workspace shared key"
    echo "   -u         Local user to update files ownership"
    echo "   -m         Ingest Mordor datasets"
    echo
    echo "Examples:"
    echo " $0 -i <Log Analytics workspace id> -c <Endpoint=sb://xxxxx> -e <Event hub name> -k <Log Analytics workspace shared key> -u wardog -m"
    echo " "
    exit 1
}

# ************ Command Options **********************
while getopts :i:c:e:k:u:mh option
do
    case "${option}"
    in
        i) WORKSPACE_ID=$OPTARG;;
        c) EVENTHUB_CONNECTIONSTRING=$OPTARG;;
        e) EVENTHUB_NAME=$OPTARG;;
        k) WORKSPACE_KEY=$OPTARG;;
        u) LOCAL_USER=$OPTARG;;
        m) MORDOR_MODE="TRUE";;
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

# ****** Installing latest docker compose
if [ -x "$(command -v docker-compose)" ]; then
    echo "removing docker-compose.."
    rm $(which docker-compose)
fi

echo "Installing docker-compose.."
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
curl -L https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "creating local logstash folders"
mkdir -p /opt/logstash/scripts
mkdir -p /opt/logstash/pipeline
mkdir -p /opt/logstash/config
mkdir -p /opt/datasets

echo "Downloading logstash files locally to be mounted to docker container"
wget -O /opt/logstash/scripts/logstash-entrypoint.sh https://raw.githubusercontent.com/hunters-forge/Blacksmith/azure/templates/azure/Sentinel2Go/logstash/scripts/logstash-entrypoint.sh
wget -O /opt/logstash/pipeline/eventhub-input.conf https://raw.githubusercontent.com/hunters-forge/Blacksmith/azure/templates/azure/Sentinel2Go/logstash/pipeline/eventhub-input.conf
wget -O /opt/logstash/pipeline/loganalytics-output.conf https://raw.githubusercontent.com/hunters-forge/Blacksmith/azure/templates/azure/Sentinel2Go/logstash/pipeline/loganalytics-output.conf
wget -O /opt/logstash/config/logstash.yml https://raw.githubusercontent.com/hunters-forge/Blacksmith/azure/templates/azure/Sentinel2Go/logstash/config/logstash.yml
wget -O /opt/logstash/docker-compose.yml https://raw.githubusercontent.com/hunters-forge/Blacksmith/azure/templates/azure/Sentinel2Go/logstash/docker-compose.yml
wget -O /opt/logstash/Dockerfile https://raw.githubusercontent.com/hunters-forge/Blacksmith/azure/templates/azure/Sentinel2Go/logstash/Dockerfile

if [[ $MORDOR_MODE ]]; then
    wget -O /opt/logstash/pipeline/json-file-input.conf https://raw.githubusercontent.com/hunters-forge/Blacksmith/azure/templates/azure/Sentinel2Go/logstash/pipeline/json-file-input.conf

    echo "Installing Git.."
    apt install -y git

    echo "Cloning Mordor repo.."
    git clone https://github.com/hunters-forge/mordor.git /opt/mordor

    echo "Decompressing every small mordor dataset.."
    cd /opt/mordor/datasets/small/
    find . -type f -name "*.tar.gz" -print0 | xargs -0 -I{} tar xf {} -C /opt/datasets/
fi

chown -R $LOCAL_USER:$LOCAL_USER /opt/logstash/* /opt/datasets/*
chmod +x /opt/logstash/scripts/logstash-entrypoint.sh

export WORKSPACE_ID="$WORKSPACE_ID"
export EVENTHUB_CONNECTIONSTRING="${EVENTHUB_CONNECTIONSTRING};EntityPath=${EVENTHUB_NAME}"
export WORKSPACE_KEY="$WORKSPACE_KEY"

docker-compose -f /opt/logstash/docker-compose.yml up --build -d