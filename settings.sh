#!/bin/bash
set -x
source "credentials.sh"
source "definitions.sh"

#Push eBay credentials to Azure as App settings
az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings "EBAY_APPID=$EBAY_APPID"
az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings "EBAY_DEVID=$EBAY_DEVID"
az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings "EBAY_CERTID=$EBAY_CERTID"
az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings "EBAY_TOKEN=$EBAY_TOKEN"
az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings "EBAY_SITEID=$EBAY_SITEID"

#Retrieve these credentials locally
func azure functionapp fetch-app-settings $functionAppName