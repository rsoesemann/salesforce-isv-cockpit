@IsTest
private class SetupRetryUnparseable_Test {

    private static List<String> mails;

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


    @IsTest
    private static void run() {

        // Setup
        setup();
        
        insert new AppError__c(txl_FullMailBody__c = mails[5]);

        SetupRetryUnparseable step = new SetupRetryUnparseable();
        System.assertEquals(1, step.unassigned);


        // Exercise
        step.run();


        // Verify
        System.assertEquals(0, step.unassigned);
    }
}