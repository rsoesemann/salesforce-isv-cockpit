public with sharing class SetupRetryUnparseable extends BatchSetupStep {

	// PUBLIC

	public override ApexPages.Message getStatus() {
		ApexPages.Message result = super.getStatus();

		if(result == null) {
			Integer unassigned = [SELECT Count() FROM AppError__c WHERE lkp_License__c = NULL];
			ApexPages.Severity severity = (unassigned > 0) ? ApexPages.Severity.WARNING : ApexPages.Severity.CONFIRM;
			String message = unassigned + ' AppErrors are not assigned. Reparse them?';
			result = new ApexPages.Message(severity, message);
		}

		return result;
	}


	public List<SObject> start(Database.BatchableContext ctx) {
		return [SELECT Id FROM AppError__c WHERE lkp_License__c = NULL];
	}


	public void execute(Database.BatchableContext ctx, List<AppError__c> errors) {
		ParseAppErrors.parseAlways = true;
        update errors;
	}


	public void finish(Database.BatchableContext ctx) { }
}