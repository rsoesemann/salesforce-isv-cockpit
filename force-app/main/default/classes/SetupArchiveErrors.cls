public with sharing class SetupArchiveErrors extends SetupStep {

    private static final String JOB_NAME = 'LmaAppCockpit_ArchiveErrors';

    private CronTrigger job;

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
        String message = 'To automatically archive AppErrors ';
        message += (job!=null) ? setupLink('/DeploymentSettings/home', 'Deployment Settings') + ' and a ' + setupLink('ScheduledJobs/home', 'Scheduled Job') + ' have been created.'
                               : 'DeploymentSettings and a Scheduled Job need to be created.';
        message += ' (' + archived + ' errors were archived as Big Objects since last run.)';
        return new ApexPages.Message(severity, message);
    }


    public override PageReference run() {
        allowChangingOfScheduledJobs();
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


    // PRIVATE

    private void reschedule() {
        System.purgeOldAsyncJobs(Date.today().addDays(1));

        if(job != null) {
            System.abortJob(job.Id);
        }

        System.schedule(JOB_NAME + '#' + filter.trim(), cronExpression, archiveCommand());
    }


    private void allowChangingOfScheduledJobs() {
        MetadataService.DeploymentSettings setting = new MetadataService.DeploymentSettings();
        setting.doesSkipAsyncApexValidation = true;

        overwrite(setting);
    }


    private ArchiveRecords archiveCommand() {
        return new ArchiveRecords(AppError__c.SObjectType, ArchivedAppError__b.SObjectType, filter);
    }
}