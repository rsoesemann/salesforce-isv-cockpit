#!/bin/bash

clear
source `dirname $0`/local-config.sh

rm -rf ./mdapi
# sfdx force:auth:web:login -a $PACKAGING_ORG_ALIAS
sfdx force:source:convert -r ./force-app  -d ./mdapi --loglevel error
sfdx force:mdapi:deploy -d ./mdapi -l RunLocalTests -u $PACKAGING_ORG_ALIAS -w 15
