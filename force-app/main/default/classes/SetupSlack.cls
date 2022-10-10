public with sharing class SetupSlack extends SetupStep {

    private static final String NOTIFICATION_CHANNEL = '#isv-cockpit';

    // PUBLIC

    public Settings__c settings { 
        get {
            Settings__c existing = Settings__c.getOrgDefaults();
            return (existing != null) ? existing : new Settings__c(); 
        }
        private set; 
    }

    public override ApexPages.Message getStatus() {
        if(isActive) {
            String address = service.LocalPart + '@' + service.EmailDomainName;
            String link = '<em><a href="/lightning/setup/EmailToApexFunction/page?address=%2Femail-admin%2Fservices%2FdetailEmailServicesAddress.apexp%3Fid%3D' + service.Id + '">' + address + '</a></em>';
            String message = String.format('An Email Service is set up to receive error emails. Configure your Managed Packages to send errors to: {0}.<br/><br/>' +
                                           '{1} for {2} Email Tokenizers is available.',
                             new List<String>{ link, setupLink('m00', 'CustomMetadata', 'Custom Metadata'), ''+ tokenizers.size()});
            return new ApexPages.Message(ApexPages.Severity.CONFIRM, message);
        }
        else {
            return new ApexPages.Message(ApexPages.Severity.WARNING, 'An Email Service is required to allow the tool to receive app errors.');
        }
    }

    
    public override Boolean getShowButtonOnSuccess() {
        return true;
    }


    public override String buttonLabel() {
        return 'Save';
    }


    public override PageReference run() {
        upsert settings;
    }
}