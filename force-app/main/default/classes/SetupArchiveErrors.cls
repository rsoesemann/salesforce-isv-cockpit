public with sharing class SetupArchiveErrors extends SetupStep {

    private static final String JOB_NAME = 'LmaAppCockpit_ArchiveErrors';

    private List<CronTrigger> jobs = [SELECT CronExpression FROM CronTrigger WHERE CronJobDetail.Name = :JOB_NAME];

    public String cronExpression { get; set; }
    public String filter { get; set; }


    // CONSTRUCTOR

    public SetupArchiveErrors() {
        cronExpression = (jobs.isEmpty()) ?  '0 0 1 * * ?' : jobs[0].CronExpression;
        filter = (jobs.isEmpty()) ? 'LastModifiedDate < LAST_N_DAYS:265' : '???';
    }


    // PUBLIC

    public override ApexPages.Message getStatus() {
        Boolean jobExists = (!jobs.isEmpty());
        ApexPages.Severity severity = (jobExists) ? ApexPages.Severity.CONFIRM : ApexPages.Severity.WARNING;
        String message = 'To automatically archive AppErrors (as BigObjects) ';
        message += (jobExists)
                        ? setupLink('/DeploymentSettings/home', 'Deployment Settings') + ' and a ' + setupLink('ScheduledJobs/home', 'Scheduled Job') + ' have been created.'
                        : 'DeploymentSettings and a Scheduled Job need to be created.';

        return new ApexPages.Message(severity, message);
    }


    public override PageReference run() {
        allowChangingOfScheduledJobs();
        reschedule();

        return currentPage();
    }


    // Note: Allow people to overwrite job
    public override Boolean getShowButtonOnSuccess() {
        return true;
    }


    public override String buttonLabel() {
        return 'Save';
    }


    public PageReference runNow() {
        new ArchiveRecords(AppError__c.SObjectType, ArchivedAppError__b.SObjectType, filter).execute();
        return currentPage();
    }


    // PRIVATE

    private void reschedule() {
        System.purgeOldAsyncJobs(Date.today().addDays(1));

        for(CronTrigger job : jobs) {
            System.abortJob(job.Id);
        }

        System.schedule(JOB_NAME, cronExpression, 
                        new ArchiveRecords(AppError__c.SObjectType, ArchivedAppError__b.SObjectType, filter));
    }


    private void allowChangingOfScheduledJobs() {
        MetadataService.DeploymentSettings setting = new MetadataService.DeploymentSettings();
        setting.doesSkipAsyncApexValidation = true;

        overwrite(setting);
    }
}