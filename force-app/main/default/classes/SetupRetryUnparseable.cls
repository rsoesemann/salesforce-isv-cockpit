public with sharing class SetupRetryUnparseable extends SetupStep {

    // PUBLIC

    public override ApexPages.Message getStatus() {
        Integer unassigned = [SELECT Count() FROM AppError__c WHERE lkp_License__c = NULL];
        ApexPages.Severity severity = (unassigned > 0) ? ApexPages.Severity.WARNING  : ApexPages.Severity.CONFIRM;

        return new ApexPages.Message(severity, unassigned + ' AppErrors are not assigned. Reparse them?');
    }


    public override String buttonLabel() {
        return 'Execute';
    }


    public override PageReference run() {
        try {
            // Note: Even if Body is unchanged
            ParseAppErrors.parseAlways = true;
            update [SELECT Id FROM AppError__c WHERE lkp_License__c = NULL LIMIT 100];
        }
        catch(Exception ex) {
            ApexPages.addMessages(ex);
        }

        return null;
    }
}