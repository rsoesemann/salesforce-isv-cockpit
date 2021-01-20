public with sharing class SetupRetryUnparseable extends SetupStep {

    private List<AppError__c> errors;

    public Integer unassigned  {
        get {
            errors = [SELECT txl_FullMailBody__c FROM AppError__c WHERE txt_OrgId__c = NULL OR txt_Namespace__c = NULL];
            return errors.size();
        }
        private set;
    }


    // PUBLIC

    public override ApexPages.Message getStatus() {
        ApexPages.Severity severity = (unassigned > 0) ? ApexPages.Severity.WARNING  : ApexPages.Severity.CONFIRM;

        return new ApexPages.Message(severity, unassigned + ' AppErrors are not assigned. Reparse them?');
    }


    public override String buttonLabel() {
        return 'Execute';
    }


    public override PageReference run() {
        try {
            for(AppError__c error : errors) {
                error.txl_FullMailBody__c += ' .';
            }
            
            update errors;
        }
        catch(Exception ex) {
            ApexPages.addMessages(ex);
        }

        return null;
    }
}