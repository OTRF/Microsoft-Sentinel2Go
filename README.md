# Azure Sentinel To-Go!

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fdev%2Fazuredeploy.json)

Azure Sentinel2Go is an open source project developed to expedite the deployment of an Azure Sentinel lab along with other Azure resources and a data ingestion pipeline to consume pre-recorded datasets for research purposes. It also comes with the option to ingest pre-recorded datasets from the [Mordor project](https://mordordatasets.com/) right at deployment time.

# Media

For more information about the development of this project, feel free to check out the following resources:

* [Azure Sentinel To-Go (Part-1): A lab w/ Prerecorded Data 😈 & a Custom Logs Pipe via ARM Templates 🚀](https://techcommunity.microsoft.com/t5/azure-sentinel/azure-sentinel-to-go-sentinel-lab-w-prerecorded-data-amp-a/ba-p/1260191)

# Author

* Roberto Rodriguez ([@Cyb3rWard0g](https://twitter.com/Cyb3rWard0g))

# Getting Started

There are a few things that you can do with this project. This project is intended for research purposes, so I highly recommend to create a new resource group in your subscription to not interfere with any other system in the same resource while deploying VMs needed for some of the features provided by this Azure Resource Manager (ARM) template.

## Ingest Mordor Datasets

1) Click on the **Deploy to Azure** badge
2) Set the following parameters:
    * Subscription
    * Resource Group
    * Workspace Name
    * Deploy Custom Logs Pipeline: Logstash
    * Add to Cart: mordor-small-datasets(1.1GB) or mordor-large-apt29(2GB)
    * Admin Username (Username for Linux VM - Logstash)
    * Admin Password (Password for Linux VM - Logstash)