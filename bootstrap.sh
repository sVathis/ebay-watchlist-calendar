#!/bin/bash
set -x
source "credentials.sh"
source "definitions.sh"

#Create Resource Group, Storage Account & FunctionApp in Azure
az group create --name $rgName --location $location
az storage account create --name $storageName --location $location --resource-group $rgName --sku Standard_LRS
az functionapp create --name $functionAppName --os-type Linux --storage-account $storageName --consumption-plan-location $location --resource-group $rgName --runtime python
az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings FUNCTIONS_EXTENSION_VERSION=~4