#!/bin/bash
set -x
source "credentials.sh"
source "definitions.sh"

#Create Resource Group, Storage Account & FunctionApp in Azure
az group create --name $rgName --location $location
az storage account create --name $storageName --location $location --resource-group $rgName --sku Standard_LRS
az functionapp create --name $functionAppName --os-type Linux --storage-account $storageName --consumption-plan-location $location --resource-group $rgName --runtime python
az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings FUNCTIONS_EXTENSION_VERSION=~3

#Push eBay credentials to Azure as App settings
az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings "EBAY_APPID=$EBAY_APPID"
az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings "EBAY_DEVID=$EBAY_DEVID"
az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings "EBAY_CERTID=$EBAY_CERTID"
az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings "EBAY_TOKEN=$EBAY_TOKEN"
az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings "EBAY_SITEID=$EBAY_SITEID"

#Retrieve these credentials locally
func azure functionapp fetch-app-settings $functionAppName