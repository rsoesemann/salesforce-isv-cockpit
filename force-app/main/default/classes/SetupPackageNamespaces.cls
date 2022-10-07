public with sharing class SetupPackageNamespaces extends SetupStep {

    // PUBLIC

    public override ApexPages.Message getStatus() {
        Integer total = [SELECT Count() FROM sfLma__Package__c WITH USER_MODE];
        Integer noNs = [SELECT Count() FROM sfLma__Package__c WHERE txt_Namespace__c = NULL WITH USER_MODE];
        
        ApexPages.Severity severity = (total > 0 && noNs > 0) ? ApexPages.Severity.WARNING 
            												  : ApexPages.Severity.CONFIRM;

        return new ApexPages.Message(severity, noNs + ' of ' + total + ' need to be activated for App Error tracking.');
    }


    public override String buttonLabel() {
        return 'Execute';
    }


    public override PageReference run() {
        List<sfLma__Package__c> packages = [SELECT sfLma__Package_ID__c FROM sfLma__Package__c 
                                            WHERE txt_Namespace__c = NULL WITH USER_MODE];
        for(sfLma__Package__c pck : packages) {
            String result = query('SELECT NamespacePrefix FROM SubscriberPackage WHERE Id = \'' + pck.sfLma__Package_ID__c + '\'');
            pck.txt_Namespace__c = JSON2Apex.parse(result).records[0].NamespacePrefix.toUpperCase();
        }
        
        update packages; // update as user packages; fails due to https://trailhead.salesforce.com/de/trailblazer-community/feed/0D54S00000HDRKgSAP

        return null;
    }


    // PRIVATE

    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')  // Note: NamedCreds can't be used for API Loopback calls
    private String query(String soql) {
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('GET');
        request.setEndpoint(URL.getOrgDomainUrl().toExternalForm()
                                + '/services/data/v45.0/tooling/query/?q=' + EncodingUtil.urlEncode(soql, 'UTF-8'));

        HttpResponse response = new Http().send(request);
        return response.getBody();
    }
}