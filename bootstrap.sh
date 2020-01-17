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
#az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings "EBAYAPPID=$EBAYAPPID"
#az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings "EBAYDEVID=$EBAYDEVID"
#az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings "EBAYCERTID=$EBAYCERTID"
#az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings "EBAYTOKEN=$EBAYTOKEN"
#az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings "EBAYSITEID=$EBAYSITEID"

az functionapp identity assign --name $functionAppName --resource-group $rgName

#Create keyvault and store secrets
az keyvault create --name $vaultname --resource-group $rgName --location $location
az keyvault secret set --vault-name $vaultname --name EBAYAPPID --value $EBAYAPPID
az keyvault secret set --vault-name $vaultname --name EBAYDEVID --value $EBAYDEVID
az keyvault secret set --vault-name $vaultname --name EBAYCERTID --value $EBAYCERTID
az keyvault secret set --vault-name $vaultname --name EBAYTOKEN --value $EBAYTOKEN
az keyvault secret set --vault-name $vaultname --name EBAYSITEID --value $EBAYSITEID

principalId=$(az functionapp identity show -n $functionAppName -g $rgName --query principalId -o tsv)
tenantId=$(az functionapp identity show -n $functionAppName -g $rgName --query tenantId -o tsv)

az keyvault set-policy -n $vaultname -g $rgName --object-id $principalId --secret-permissions get

EBAYAPPID_SECRET=$(az keyvault secret show -n EBAYAPPID --vault-name $vaultname --query "id" -o tsv)
EBAYDEVID_SECRET=$(az keyvault secret show -n EBAYDEVID --vault-name $vaultname --query "id" -o tsv)
EBAYCERTID_SECRET=$(az keyvault secret show -n EBAYCERTID --vault-name $vaultname --query "id" -o tsv)
EBAYTOKEN_SECRET=$(az keyvault secret show -n EBAYTOKEN --vault-name $vaultname --query "id" -o tsv)
EBAYSITEID_SECRET=$(az keyvault secret show -n EBAYSITEID --vault-name $vaultname --query "id" -o tsv)

az functionapp config appsettings set -n $functionAppName -g $rgName --settings "EBAYAPPID=@Microsoft.KeyVault(SecretUri=$EBAYAPPID_SECRET)"
az functionapp config appsettings set -n $functionAppName -g $rgName --settings "EBAYDEVID=@Microsoft.KeyVault(SecretUri=$EBAYDEVID_SECRET)"
az functionapp config appsettings set -n $functionAppName -g $rgName --settings "EBAYCERTID=@Microsoft.KeyVault(SecretUri=$EBAYCERTID_SECRET)"
az functionapp config appsettings set -n $functionAppName -g $rgName --settings "EBAYTOKEN=@Microsoft.KeyVault(SecretUri=$EBAYTOKEN_SECRET)"
az functionapp config appsettings set -n $functionAppName -g $rgName --settings "EBAYSITEID=@Microsoft.KeyVault(SecretUri=$EBAYSITEID_SECRET)"

az functionapp config appsettings list --name $functionAppName -g $rgName
#Retrieve these credentials locally
func azure functionapp fetch-app-settings $functionAppName