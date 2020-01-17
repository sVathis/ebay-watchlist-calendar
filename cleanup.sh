#!/bin/bash
set -x
source "definitions.sh"

 az group delete --name $rgName --yes
 rm local.settings.json
 #az keyvault delete --name $vaultname --resource-group $rgName 