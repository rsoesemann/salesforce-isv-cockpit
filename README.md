# Salesforce ISV Cockpit 

The ISV Cockpit is a native Salesforce App that extends the Salesforce LMA in your Partner Business Org (PBO) and helps you monitor the health of your apps and proactively support your subscribers in error cases.

**Features:**

- Auto-Links Errors to **Licence Management App** (=LMA) objects (Accounts, Packages, Versions, Licences)
- **Custom Metadata** Tokenizer for flexible Email Parsing
- Understand your Apps help with **Reports and Dashboards**
- Notify **Slack** Channel on Errors
- Archive and Restore Errors using **Big Object**
- Fetches and reports on **App Analytics** Summary data
- Explain errors and fixes using **OpenAI API** integration

## TL;DR - Click for Video Demo!

[![](http://img.youtube.com/vi/m0m6TH8-mnM/hqdefault.jpg)](https://youtu.be/m0m6TH8-mnM "")

## How does it work?

Managed Packages have an option to send out app errors to an email address defined during Package upload. We use this mechanism and let our App receive and parse those emails. In combination with the information in the LMA app, we can perfectly assign each incoming error to a customer account, a package, package version, and license. But we can do more. We also extract information about the type of error and where it occurred.

All this information is stored in a single Custom Object and can be easily used for reporting and sophisticated support workflows.

## How can I use and extends this?

The project was built as a flexible unnamespaced SFDX project. The repo contains all the scripts to automatically build dev scratch orgs with the LMA installed and sample data to play with.

From there you can either build Unlocked Packages from it or even push it into a Packaging org using the deployMetadata.sh script.

Feel free to fork the repo and extend it. We would love to get improvements as Pull Request from you. Or create issues when you find a problem but don't want to fix it on your own.
