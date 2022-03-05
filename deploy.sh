#!/bin/bash
set -x
source "definitions.sh"

func azure functionapp publish $functionAppName --python 
