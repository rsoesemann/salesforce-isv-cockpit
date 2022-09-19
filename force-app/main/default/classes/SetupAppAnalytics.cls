public with sharing class SetupAppAnalytics extends SetupStep implements Schedulable {

    public static final String JOB_NAME = 'AppCockpit_RequestAppAnalytics';

    public CronTrigger job { get; private set; }
    public String cronExpression { get; set; }


    // CONSTRUCTOR

    public SetupAppAnalytics() {
        cronExpression = '0 0 1 * * ?';

        for(CronTrigger job : [SELECT CronJobDetail.Name, CronExpression FROM CronTrigger WHERE CronJobDetail.Name LIKE :JOB_NAME]) {
            this.job = job;
            cronExpression = job.CronExpression;
        }
    }


    // PUBLIC

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
        return 'Save';
    }


    public override PageReference run() {
        System.purgeOldAsyncJobs(Date.today().addDays(1));

        if(job != null) {
            System.abortJob(job.Id);
        }

        System.schedule(JOB_NAME, cronExpression, this);

        return currentPage();
    }


    public PageReference runNow() {
        requestLogs();

        return currentPage();
    }


    // Schedulable

    public void execute(System.SchedulableContext ctx) {
        requestLogs();
    }



    // PRIVATE

    private AppAnalyticsQueryRequest requestLogs() {
        AppAnalyticsQueryRequest request = new AppAnalyticsQueryRequest();
        request.DataType = 'PackageUsageLog';
        request.StartTime = Datetime.now().addDays(-1);
        request.EndTime = Datetime.now();
        request.PackageIds = String.join(packageIds(), ',');
        insert request;

        return request;
    }

    
    private List<Id> packageIds() {
        List<Id> result = new List<Id>();

        for(sfLma__Package__c p : [SELECT sfLma__Package_ID__c FROM sfLma__Package__c WHERE txt_Namespace__c <> NULL]) {
            result.add(p.sfLma__Package_ID__c);
        }

        return result;
    }
} 