public with sharing class SetupArchiveErrors extends SetupStep {

    private static final String JOB_NAME = 'AppCockpit_ArchiveErrors';

    public CronTrigger job { get; private set; }
    public String cronExpression { get; set; }
    public String filter { get; set; }
    public Integer archived { get; set; }


    // CONSTRUCTOR

    public SetupArchiveErrors() {
        cronExpression = '0 0 1 * * ?';
        filter = 'LastModifiedDate < LAST_N_DAYS:265';
        archived = [SELECT Id FROM ArchivedAppError__b LIMIT 100].size();

        String jobName = JOB_NAME + '%';
        for(CronTrigger cron : [SELECT CronJobDetail.Name, CronExpression, PreviousFireTime 
                               FROM CronTrigger WHERE CronJobDetail.Name LIKE :jobName LIMIT 1]) {
            job = cron; 
            cronExpression = job.CronExpression;
            filter = job.CronJobDetail.Name.substringAfter('#');
            archived = Math.max(archived, [SELECT Id FROM ArchivedAppError__b WHERE dtm_ArchivedDate__c < :job.PreviousFireTime].size());                            
        }
    }


    // PUBLIC

    public override ApexPages.Message getStatus() {
        ApexPages.Severity severity = (job!=null) ? ApexPages.Severity.CONFIRM : ApexPages.Severity.WARNING;
        String message = 'To automatically archive AppErrors a ';
        message += (job!=null) ? setupLink('ScheduledJobs/home', 'Scheduled Job') + ' has been created.'
                               : 'Scheduled Job needs to be created.';
        message += ' (' + archived + ' errors were archived as Big Objects since last run.)';
        return new ApexPages.Message(severity, message);
    }


    public override PageReference run() {
        reschedule();

        return currentPage();
    }


    public override Boolean getShowButtonOnSuccess() {
        return true;
    }


    public override String buttonLabel() {
        return 'Save';
    }


    public PageReference runNow() {
        archiveCommand().execute();
        return currentPage();
    }


    public Boolean getIsSupported() {
        Boolean result = true;

        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/v51.0/async-queries/');
            request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
            request.setHeader('Content-Type', 'application/json');
            request.setMethod('GET');

            if(new Http().send(request).getStatusCode() != 200) {
                result = false;
            }
        }
        catch(Exception ignored) {
            result = false;
        }

        return result;
    }


    // PRIVATE

    private void reschedule() {
        System.purgeOldAsyncJobs(Date.today().addDays(1));

        if(job != null) {
            System.abortJob(job.Id);
        }

        System.schedule(JOB_NAME + '#' + filter.trim(), cronExpression, archiveCommand());
    }


    private ArchiveRecords archiveCommand() {
        return new ArchiveRecords(AppError__c.SObjectType, ArchivedAppError__b.SObjectType, filter);
    }
} 