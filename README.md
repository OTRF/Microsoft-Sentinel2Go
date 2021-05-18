# Azure Sentinel To-Go!

[![Open_Threat_Research Community](https://img.shields.io/badge/Open_Threat_Research-Community-brightgreen.svg)](https://twitter.com/OTR_Community)
[![Open Source Love](https://badges.frapsoft.com/os/v3/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)

<img src="resources/images/logo.png" alt="Azure Sentinel To-Go!" width="650"/>

Azure Sentinel2Go is an open source project developed to expedite the deployment of an Azure Sentinel lab along with other Azure resources and a data ingestion pipeline to consume pre-recorded datasets for research purposes. It also comes with the option to ingest pre-recorded datasets from the [Mordor project](https://mordordatasets.com/) right at deployment time.

# Getting Started

There are a few things that you can do with this project. This project is intended for research purposes, so I highly recommend to create a new resource group in your subscription to not interfere with any other system in the same resource group. Take a look at the different scenarios that you can deploy in the section below.

# Grocery List - Deployment Options

A few deployments available through Azure Sentinel To-go!

| Items | Deploy | Deploy US Gov |
| :---| :---| :--- |
| [Azure Sentinel](https://github.com/OTRF/Azure-Sentinel2Go/tree/master/azure-sentinel) | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fazure-sentinel%2Fazuredeploy.json) | [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fazure-sentinel%2Fazuredeploy.json) |
| [Azure Sentinel + Custom Log Pipeline](https://github.com/OTRF/Azure-Sentinel2Go/tree/master/grocery-list/custom-log-pipeline) | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2Fcustom-log-pipeline%2Fazuredeploy.json) | [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2Fcustom-log-pipeline%2Fazuredeploy.json) |
| [Azure Sentinel + Win10 Workstations](https://github.com/OTRF/Azure-Sentinel2Go/tree/master/grocery-list/Win10) | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10%2Fazuredeploy.json) | [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10%2Fazuredeploy.json) |
| [Azure Sentinel + Win10 + AD](https://github.com/OTRF/Azure-Sentinel2Go/tree/master/grocery-list/Win10-AD) | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-AD%2Fazuredeploy.json) | [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-AD%2Fazuredeploy.json) |
| [Azure Sentinel + Win10 + AD + ADFS](https://github.com/OTRF/Azure-Sentinel2Go/tree/master/grocery-list/Win10-AD-ADFS) | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-AD-ADFS%2Fazuredeploy.json) | [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-AD-ADFS%2Fazuredeploy.json) |
| [Azure Sentinel + Win10 + AD + MXS](https://github.com/OTRF/Azure-Sentinel2Go/tree/master/grocery-list/Win10-AD-MXS) | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-AD-MXS%2Fazuredeploy.json) | [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-AD-MXS%2Fazuredeploy.json) |
| [Azure Sentinel + Win10 + Palo Alto Networks VM-Series Firewall](https://github.com/OTRF/Azure-Sentinel2Go/tree/master/grocery-list/Win10-PAN-FW) | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-PAN-FW%2Fazuredeploy.json) | [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-PAN-FW%2Fazuredeploy.json) |
| [Azure Sentinel + Linux (Ubuntu,CentOS,RHEL)](https://github.com/OTRF/Azure-Sentinel2Go/tree/master/grocery-list/Linux) | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2FLinux%2Fazuredeploy.json) | [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2FLinux%2Fazuredeploy.json) |

# Media

For more information about the development of this project, feel free to check out the following resources:

* [Azure Sentinel To-Go (Part 1): A lab w/ Prerecorded Data 😈 & a Custom Logs Pipe via ARM Templates 🚀](https://techcommunity.microsoft.com/t5/azure-sentinel/azure-sentinel-to-go-sentinel-lab-w-prerecorded-data-amp-a/ba-p/1260191)
* [Azure Sentinel To-Go (Part 2): Integrating a Basic Windows Lab 🧪 via ARM Templates 🚀](https://techcommunity.microsoft.com/t5/azure-sentinel/azure-sentinel-to-go-part2-integrating-a-basic-windows-lab-via/ba-p/1742165)

# Author

* Roberto Rodriguez ([@Cyb3rWard0g](https://twitter.com/Cyb3rWard0g))