@IsTest
private class SetupRetryUnparseable_Test {

    private static List<String> mails;

    @IsTest
    private static void run() {

        // Setup
        setup();

        fflib_SObjectDomain.getTriggerEvent(AppErrors.class).disableAll();
        insert new AppError__c(txl_FullMailBody__c = mails[6]);
        fflib_SObjectDomain.getTriggerEvent(AppErrors.class).enableAll();

        SetupRetryUnparseable step = new SetupRetryUnparseable();
        System.assertEquals(ApexPages.Severity.WARNING, step.getStatus().getSeverity());


        // Exercise
        step.run();


        // Verify
        System.assertEquals(ApexPages.Severity.CONFIRM, step.getStatus().getSeverity());
    }


    // HELPER

    private static void setup() {
        Account_t a = new Account_t();
        LmaPackage p = new LmaPackage().name('App A').ns('NSA');
        LmaVersion v = new LmaVersion(p).name('v1');
        new LmaLicense(a, v)
                .org('00D000000000001')
                .persist();

        StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = 'error_mails_txt'];
        mails = resource.Body.toString().split('&');
    }
}