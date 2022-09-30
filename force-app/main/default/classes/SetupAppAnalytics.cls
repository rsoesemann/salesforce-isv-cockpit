public with sharing class SetupAppAnalytics extends SetupStep  {

    // PUBLIC

    public CronTrigger job { get { return RequestAppAnalytics.queryJob(); } private set; }


    public String cronExpression { 
        get { return (job != null) ? job.CronExpression : '0 0 1 * * ?'; } set; 
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

    private void activate() {
        new RequestAppAnalytics(job).activate();
    }


    private void deactivate() {
        new RequestAppAnalytics(job).deactivate();
    }
}