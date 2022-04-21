public with sharing class SetupRetryUnparseable extends BatchSetupStep {

    public Integer batchSize {
        get {
            if(batchSize == null) {
                batchSize =  1;
            }
            return batchSize;
        }
        set; 
    }

	public Integer unassigned { 
		get {
            return [SELECT Count() FROM AppError__c WHERE lkp_License__c = NULL OR txt_ExceptionType__c = NULL];
        }
        private set; 
	}

	
	// PUBLIC

	public override ApexPages.Message getStatus() {
		ApexPages.Message result = super.getStatus();

		if(result == null) {
			ApexPages.Severity severity = (unassigned > 0) ? ApexPages.Severity.WARNING : ApexPages.Severity.CONFIRM;
			result = new ApexPages.Message(severity, unassigned + ' AppErrors are not assigned. Reparse them?');
		}

		return result;
	}

	public override Integer batchSize() {
		return batchSize;
	}


	public List<SObject> start(Database.BatchableContext ctx) {
		return [SELECT Id FROM AppError__c WHERE lkp_License__c = NULL OR txt_ExceptionType__c = NULL];
	}


	public void execute(Database.BatchableContext ctx, List<AppError__c> errors) {
		ParseAppErrors.parseAlways = true;
        update errors;
	}


	public void finish(Database.BatchableContext ctx) { }
}