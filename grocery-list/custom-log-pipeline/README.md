# Azure Sentinel + Logstash + Event Hub

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2Fcustom-log-pipeline%2Fazuredeploy.json)

[![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2Fcustom-log-pipeline%2Fazuredeploy.json)


## Grocery Items

* Azure Sentinel
* Logstash Server
    * `logstash-output-azure_loganalytics` plugin
* Azure Event Hub
* [OPTIONAL] Mordor Datasets

## Ingesting Mordor Datasets?

1) Click on the **Deploy to Azure** badge
2) Set the following parameters:
    * Subscription
    * Resource Group
    * Workspace Name
    * Deploy Custom Logs Pipeline: Logstash
    * Add to Cart: mordor-small-datasets(1.1GB) or mordor-large-apt29(2GB)
    * Admin Username (Username for Linux VM - Logstash)
    * Admin Password (Password for Linux VM - Logstash)