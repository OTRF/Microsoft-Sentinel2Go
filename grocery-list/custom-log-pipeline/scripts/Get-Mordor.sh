#!/bin/bash

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

usage(){
    echo " "
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -d         What Mordor datasets you would like to import (SMALL_DATASETS or APT29"
    echo
    echo "Examples:"
    echo " $0 -d SMALL_DATASETS"
    echo " $0 -d LARGE_APT29"
    echo " "
    exit 1
}

# ************ Command Options **********************
while getopts :d:h option
do
    case "${option}"
    in
        d) MORDOR_DATASETS=$OPTARG;;
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

if [ -z "$MORDOR_DATASETS" ]; then
  echo "[!] Make sure you provide values for the Mordor Datasets (-d)"
  usage
else
    case $MORDOR_DATASETS in
        SMALL_DATASETS) ;;
        LARGE_APT29) ;;
        *) echo "[!] ]Not a valid dataset option"; usage; exit 1;;
    esac

    # Stopping Container
    echo "Stopping Logstash.."
    docker stop logstash
    # Adding Logstash config
    wget -O /opt/logstash/pipeline/json-file-input.conf https://raw.githubusercontent.com/OTRF/Azure-Sentinel2Go/master/grocery-list/custom-log-pipeline/logstash/pipeline/json-file-input.conf

    echo "Installing Git.."
    apt install -y git unzip

    echo "Cloning Mordor repo.."
    git clone https://github.com/hunters-forge/mordor.git /opt/mordor

    if [[ $MORDOR_DATASETS == "SMALL_DATASETS" ]]; then
        echo "Decompressing every small mordor dataset.."
        cd /opt/mordor/datasets/small/
        find . -type f -name "*.tar.gz" -print0 | xargs -0 -I{} tar xf {} -C /opt/logstash/datasets/
    elif [[ $MORDOR_DATASETS == "LARGE_APT29" ]]; then
        echo "Decompressing only APT29 Dataset.."
        cd /opt/mordor/datasets/large/apt29
        find . -type f -name "*_manual.zip" -print0 | xargs -0 -I{} unzip {} -d /opt/logstash/datasets/
    fi
    folder_size=$(du -ach /opt/logstash/datasets/ | tail -1 | cut -f1)
    echo "Extracted $folder_size in security event logs.."

    # Starting Container
    echo "Starting Logstash container"
    docker start logstash
fi