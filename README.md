# Salesforce LMA App Cockpit [![Codacy Badge](https://api.codacy.com/project/badge/Grade/ec0461b71c16496cbe88cf1b26033538)](https://www.codacy.com?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=logiclinegmbh/lma-app-cockpit&amp;utm_campaign=Badge_Grade)

## TL;DR

[![](http://img.youtube.com/vi/GTy0Lr19z34/0.jpg)](https://youtu.be/GTy0Lr19z34 "Video Demo")

## What is the App Cockpit?

The App Cockpit is a native Salesforce App that extends the Salesforce LMA and helps you monitor the health of your apps and proactivly support your subscribers in error cases.

Managed Packages have an option to send out app errors to an email address defined during Package upload. We use this mechanism and let our App receive and parse those emails. In combination with the information in the LMA app we can perfectly assign each incoming error a customer account, a package, package version and license. But we can do more. We also extract information about the type of error and where it occurred.

All this information is stored in an single Custom Object and can be easily used for reporting and sophisticated support workflows.

## Why did you built this?

As a PDO partner we help many customers each year to get their product ideas out into the AppExchange. But our support doesn't stop with that. Over the time we realized that doing support with the LMA app alone is not optimal. So we developed an internal solution which worked well for us. 

## Why did you open-source this?

For two reasons. We truly believe in Open Source. We use Open Source in our daily work and think we also have to give back. But we also think that for our customers it's even more trustworthy to know that the source code of the app that they use for support can be checked for bugs by anybody out there.

[![Deploy](https://deploy-to-sfdx.com/dist/assets/images/DeployToSFDX.svg)](https://deploy-to-sfdx.com)

## How can I use and extends this?

The project was build as a flexible unnamespaced SFDX project. The repo contains all the scripts to automatically build dev scratch orgs with the LMA installed and sample data to play with.

From there you can eighter build Unlocked Packages from it or even push it into a Packaging org using the deployMetadata.sh script.

Feel free to fork the repo and extend it. We would love to get improvements as Pull Request from you. Or create issues when you find a problem but don't wont to fix it on your own.



The LMA Cockpit is a native Salesforce App that extends the Licence Management App from Salesforce to simplify the support and continuous improvement of Managed Packages installed in multiple subscriber orgs.
Managed Packages are able to send out error emails to an email address defined during package upload. This app provides such an address and receives those error emails. It parses them and assigns them Packages, Package Versions and Licences. It also detects where in the code the error happened.
I displays this content in dashboards and makes it easily accessable. 

That way you can proactivly monitor the health of you applications in you installes customer base.
