#!/bin/bash

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

usage(){
    echo " "
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -n         EventHub Namespace"
    echo "   -c         EventHub Connection String Primary"
    echo "   -e         EventHub name"
    echo
    echo "Examples:"
    echo " $0 -n <eventhubNamespace> -c <Endpoint=sb://xxxxx> -e <Event Hub name"
    echo " "
    exit 1
}

# ************ Command Options **********************
while getopts :n:c:e:h option
do
    case "${option}"
    in
        n) EVENTHUB_NAMESPACE=$OPTARG;;
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

# ****** Installing latest kafkacat
if [ -x "$(command -v kafkacat)" ]; then
    echo "removing kafkacat.."
    apt-get remove --auto-remove -y kafkacat
fi

echo "Installing Kafkacat.."
wget https://github.com/edenhill/kafkacat/archive/debian/1.4.0-1.tar.gz
tar -xzvf 1.4.0-1.tar.gz
apt install -y librdkafka-dev libyajl-dev build-essential libsasl2-dev libsasl2-modules libssl-dev 
cd kafkacat-debian-1.4.0-1/ && ./bootstrap.sh
cp kafkacat /usr/local/bin/

echo "Installing Git.."
apt install -y git

echo "Cloning Mordor repo.."
git clone https://github.com/OTRF/mordor.git

echo "Decompressing every small mordor dataset.."
cd mordor/datasets/small/
find . -type f -name "*.tar.gz" -print0 | xargs -0 -I{} tar xf {} -C .

echo "Sending every dataset to Azure Event Hub"
filescount=$(find . -maxdepth 1 -type f -name "*.json" -printf x | wc -c)
count=0
for mordorfile in *.json; do
    count=$(($count + 1))
    echo "($count of $filescount) Sending $mordorfile .."
    kafkacat -b ${EVENTHUB_NAMESPACE}.servicebus.windows.net:9093 -t ${EVENTHUB_NAME} -X metadata.broker.list=${EVENTHUB_NAMESPACE}.servicebus.windows.net:9093 -X security.protocol=sasl_ssl -X sasl.mechanisms=PLAIN -X sasl.username=\$ConnectionString -X sasl.password="${EVENTHUB_CONNECTIONSTRING}" -X enable.ssl.certificate.verification=false -X message.max.bytes=1000000 -P -v -l $mordorfile
    sleep 5
done