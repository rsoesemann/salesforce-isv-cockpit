public abstract class BatchSetupStep extends SetupStep implements Database.Batchable<SObject> {

    private static final String JOBS_LINK = '/apexpages/setup/listAsyncApexJobs.apexp';


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
        PageReference result = null;

        if(!(new List<String>{ 'Aborted', null }).contains(batchStatus())) {
            Database.executeBatch(this);
            result = new PageReference(JOBS_LINK);
        }

		return result;
	}


	// PRIVATE

	private String batchStatus() {
		String result = null;

		for(AsyncApexJob job : [SELECT Status FROM AsyncApexJob  WHERE ApexClass.Name LIKE :className()
                                ORDER BY CreatedDate DESC LIMIT 1]) {
			result = job.Status;
		}

		return result;
	}


	private String logsLink() {
		return '<b><a href="' + JOBS_LINK + '">Apex Jobs</a></b>';
	}


    private String className() {
        return String.valueOf(this).split(':')[0];
    }
}
