#!/bin/bash

clear
source `dirname $0`/local-config.sh

sfdx force:org:delete -p -u $SCRATCH_ORG_ALIAS -v $DEV_HUB_ALIAS
sfdx force:org:create -a $SCRATCH_ORG_ALIAS -s -f config/project-scratch-def.json -d 29clear
sfdx force:package:install --package 04t30000001DWL0AAO --publishwait 5 --wait 10 -u $SCRATCH_ORG_ALIAS
sfdx force:source:push
sfdx force:user:permset:assign -n AppErrorAdmin
sfdx force:data:record:update -s User -w "Name='User User'" -v "Languagelocalekey=en_US" -u $SCRATCH_ORG_ALIAS
sfdx force:apex:execute -f scripts/createSampleData.apex -u $SCRATCH_ORG_ALIAS
sfdx force:org:open
sfdx force:apex:test:run -u $SCRATCH_ORG_ALIAS -l RunLocalTests -r human

echo "Org is set up"
