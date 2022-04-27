public with sharing class SetupReparse extends BatchSetupStep {

    public Integer batchSize {
        get {
            if(batchSize == null) {
                batchSize =  1;
            }
            return batchSize;
        }
        set; 
    }

    public String filter {
        get {
            if(filter == null) {
                filter = 'lkp_License__c = NULL OR txt_ExceptionType__c = NULL';
            }
            return filter;
        }
        set; 
    }
    
    public Integer recordCount {
        get {
            try {
                recordCount = Database.countQuery('SELECT Count() FROM AppError__c WHERE ' + filter);
            }
            catch(Exception ex) {
                ApexPages.addMessages(ex);
            }

            return recordCount;
        }
        private set; 
    }

	
	// PUBLIC

	public override ApexPages.Message getStatus() {
		ApexPages.Message result = super.getStatus();

        if(result == null) {
			ApexPages.Severity severity = (recordCount > 0) ? ApexPages.Severity.WARNING : ApexPages.Severity.CONFIRM;
			result = new ApexPages.Message(severity, 'Reparse ' + recordCount + ' AppErrors now?');
		}

		return result;
	}


	public override Integer batchSize() {
		return batchSize;
	}


    public PageReference refresh() {
        return null;
    }


	public List<SObject> start(Database.BatchableContext ctx) {
		return Database.query('SELECT Id FROM AppError__c WHERE ' + String.escapeSingleQuotes(filter));
	}


	public void execute(Database.BatchableContext ctx, List<AppError__c> errors) {
		ParseAppErrors.parseAlways = true;
        update errors;
	}


	public void finish(Database.BatchableContext ctx) { }
}