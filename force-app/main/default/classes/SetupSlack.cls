public with sharing class SetupSlack extends SetupStep {

    // PUBLIC

    public Settings__c settings { 
        get {
            if(settings == null) {
                Settings__c existing = Settings__c.getOrgDefaults();
                settings = (existing == null) ? new Settings__c(SetupOwnerId=UserInfo.getOrganizationId()) : existing;
            }
            return settings;
        }
        set; 
    }

    public override ApexPages.Message getStatus() {
        if(settings.Id == null || settings.txt_SlackChannel__c == null || settings.txt_SlackTeam__c == null ) {
            return new ApexPages.Message(ApexPages.Severity.WARNING, 'A Slack Team and Channel Id needs to be stored as Custom Setting to enable Slack notifications.');
        }
        else {
            String message = 'Your Slack Team and Channel Id was successfully stored in this <em><a target="_blank" href="/lightning/setup/CustomSettings/home">Custom Setting</a></em> to enable Slack notifications.';
            return new ApexPages.Message(ApexPages.Severity.CONFIRM, message);
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
        return currentPage();
    }
}