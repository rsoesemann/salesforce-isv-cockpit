#!/bin/bash
source `dirname $0`/config.sh

execute() {
  $@ || exit
}

if [ -z "$DEV_HUB_URL" ]; then
  echo "set default devhub user"
  execute sf config set defaultdevhubusername=$DEV_HUB_ALIAS

  echo "Deleting old scratch org"
  sf force org delete --no-prompt --target-org $SCRATCH_ORG_ALIAS
fi

echo "Creating scratch org"
execute sf force org create --setalias $SCRATCH_ORG_ALIAS --setdefaultusername --definitionfile ./config/scratch-org-def.json --durationdays 30

echo "Install dependencies"
execute sfdx force:package:install --package 04t30000001DWL0AAO --publishwait 5 --wait 10 -u $SCRATCH_ORG_ALIAS

echo "Pushing changes to scratch org"
execute sf force source push
# Will fail as your first have to go into the Org, turn Slack on and turn Slack for Apex on.

echo "Assigning permissions"
execute sf force user permset assign --perm-set-name Admin

echo "Make sure Org user is english"
sf data update record --sobject User --where "Name='User User'" --values "Languagelocalekey=en_US"

echo "Create sample data"
execute sfdx force:apex:execute -f scripts/createSampleData.apex

echo "Running Apex Tests"
execute sf apex run test --test-level RunLocalTests --wait 30 --code-coverage --result-format human

echo "Running Salesforce Code Analyser"
sfdx scanner:run --format table --target force-app --engine "pmd" --pmdconfig "ruleset.xml"
sfdx scanner:run:dfa --format table --target force-app --projectdir force-app