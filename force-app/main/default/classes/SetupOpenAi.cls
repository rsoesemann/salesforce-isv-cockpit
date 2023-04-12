public with sharing class SetupOpenAi extends SetupStep {

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
        if(settings.Id == null || settings.txt_OpenAiApiKey__c == null ) {
            return new ApexPages.Message(ApexPages.Severity.WARNING, 'An OpenAI API Key is needed to enable Insights features.');
        }
        else {
            String message = 'Your <em><a href="https://platform.openai.com/account/org-settings">OpenAI API Key</a></em> was successfully stored in this <em><a target="_blank" href="/lightning/setup/CustomSettings/home">Custom Setting</a></em> to enable AI Insights.';
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