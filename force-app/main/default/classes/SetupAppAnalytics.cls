public with sharing class SetupAppAnalytics extends SetupStep  {

    private static final String JOB_NAME = 'IsvCockpit_RequestAppAnalytics';

    // PUBLIC

    public CronTrigger job { 
        get {
            for(CronTrigger job : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE :JOB_NAME]) {
                this.job = job;
            }

            return job;
        }
        private set;
    }


    public Boolean isActive { 
        get {return (job != null); } private set; 
    }


    public override ApexPages.Message getStatus() {
        ApexPages.Severity severity = (job == null) ? ApexPages.Severity.WARNING : ApexPages.Severity.CONFIRM;
        
        String message = 'To automatically pull App Errors via App Analytics a ';
        message += (job == null) ? 'Scheduled Job needs to be created.' 
                                 : setupLink('ScheduledJobs/home', 'Scheduled Job') + ' has been created.';
        return new ApexPages.Message(severity, message);
    }


    public override Boolean getShowButtonOnSuccess() {
        return true;
    }


    public override String buttonLabel() {
        return (isActive) ? 'Deactivate' : 'Activate';
    }


    public override PageReference run() {
        if(isActive) {
            deactivate();
        }
        else {
            activate();
        }

        return currentPage();
    }


    // PRIVATE

    public void activate() {
        if(Test.isRunningTest()) {
            new RequestAppAnalytics().execute(null);
        }
        else {
            // Note: Run 3rd day of every month 0 1 0 3 1/1 ? *
            System.schedule(JOB_NAME,  '0 0 * * * ?', new RequestAppAnalytics());
        }
    }


    public void deactivate() {
        System.purgeOldAsyncJobs(Date.today().addDays(1));

        if(job != null) {
            System.abortJob(job.Id);
        }
    }
}