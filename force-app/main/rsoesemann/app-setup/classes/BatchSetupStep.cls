public abstract class BatchSetupStep extends SetupStep implements Database.Batchable<SObject> {

	// PUBLIC

	public virtual override ApexPages.Message getStatus() {
		String status = batchStatus();

		if((new List<String>{ 'Failed' }).contains(status)) {
			return new ApexPages.Message(ApexPages.Severity.ERROR, 'Execution ' + status + '. Check the ' + logsLink() + '.');
		}
		else if((new List<String>{ 'Holding', 'Queued', 'Preparing', 'Processing' }).contains(status)) {
			return new ApexPages.Message(ApexPages.Severity.INFO, 'Execution is ' + status + ' : Check the ' + logsLink());
		}

		return null;
	}


	public override String buttonLabel() {
		return 'Run';
	}


	public override PageReference run() {
        if(new List<String>{ null, 'Completed', 'Aborted' }.contains(batchStatus())) {
            Database.executeBatch(this, batchSize());
        }

		return currentPage();
	}


	public abstract Integer batchSize();

	
	// PRIVATE

	private String batchStatus() {
		String result = null;

		for(AsyncApexJob job : [SELECT Status FROM AsyncApexJob  
		                        WHERE ApexClass.Name LIKE :className()
                                ORDER BY CreatedDate DESC LIMIT 1]) {
			result = job.Status;
		}

		return result;
	}


	private String logsLink() {
		return '<b><a href="/apexpages/setup/listAsyncApexJobs.apexp">Apex Jobs</a></b>';
	}


    private String className() {
        return String.valueOf(this).split(':')[0];
    }
}