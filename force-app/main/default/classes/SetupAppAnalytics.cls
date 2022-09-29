public with sharing class SetupAppAnalytics extends SetupStep implements Schedulable {

    public static final String JOB_NAME = 'AppCockpit_RequestAppAnalytics';

    @TestVisible
    private static AppAnalyticsQueryRequest request;


    // PUBLIC

    public CronTrigger job { 
        get {
            for(CronTrigger job : [SELECT CronJobDetail.Name, StartTime, CronExpression, NextFireTime, PreviousFireTime 
                                    FROM CronTrigger WHERE CronJobDetail.Name LIKE :JOB_NAME]) {
                this.job = job;
            }
            return job;
        }
        private set; 
    }


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


    // Schedulable

    public void execute(System.SchedulableContext ctx) {
        requestLogs();
    }


    // PRIVATE

    private void activate() {
        System.schedule(JOB_NAME, cronExpression, this);
    }


    private void deactivate() {
        System.purgeOldAsyncJobs(Date.today().addDays(1));

        if(job != null) {
            System.abortJob(job.Id);
        }
    }


    private void requestLogs() {
        request = new AppAnalyticsQueryRequest();
        request.DataType = 'PackageUsageLog';
        request.PackageIds = String.join(packageIds(), ',');
        request.EndTime = job.NextFireTime;
        request.StartTime = job.NextFireTime.addMinutes(- minutesBetweenJob());

        try {
            insert request;
        }
        catch(Exception ignored) {
            // Note: In Scratch orgs this is ok
            System.debug(LoggingLevel.ERROR, '(In Scratch orgs this is ok) ' + ignored);
        }
    }


    private List<Id> packageIds() {
        List<Id> result = new List<Id>();

        for(sfLma__Package__c p : [SELECT sfLma__Package_ID__c FROM sfLma__Package__c WHERE txt_Namespace__c <> NULL]) {
            result.add(p.sfLma__Package_ID__c);
        }

        return result;
    }


    private Integer minutesBetweenJob() {
        Datetime nextRun = job.NextFireTime;
        Datetime lastRun = (job.PreviousFireTime == null) ? nextRun.addDays(-1) : job.PreviousFireTime;

        Integer result = Integer.valueOf((nextRun.getTime() - lastRun.getTime()) / (1000*60));
        return result;
    }
}