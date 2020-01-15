#!/bin/bash
set -x
source "definitions.sh"

 az group delete --name $functionAppName --yes