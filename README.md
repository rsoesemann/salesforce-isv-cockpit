# Salesforce LMA App Cockpit [![Codacy Badge](https://api.codacy.com/project/badge/Grade/ec0461b71c16496cbe88cf1b26033538)](https://www.codacy.com?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=logiclinegmbh/lma-app-cockpit&amp;utm_campaign=Badge_Grade)

The LMA Cockpit is a native Salesforce App that extends the Licence Management App from Salesforce to simplify the support and continuous improvement of Managed Packages installed in multiple subscriber orgs.
Managed Packages are able to send out error emails to an email address defined during package upload. This app provides such an address and receives those error emails. It parses them and assigns them Packages, Package Versions and Licences. It also detects where in the code the error happened.
I displays this content in dashboards and makes it easily accessable. 

That way you can proactivly monitor the health of you applications in you installes customer base.

<a href="https://githubsfdeploy.herokuapp.com?owner=logiclinegmbh&repo=lma-app-cockpit">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

