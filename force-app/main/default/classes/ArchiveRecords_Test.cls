@IsTest
private class ArchiveRecords_Test {

    private static Account_t account;
    private static LmaPackage app;
    private static LmaVersion version;
    private static LmaLicense license;
    private static List<String> mails;
    static {
        setup();   
    }


    @IsTest
    private static void happyPath() {

        // Setup
        insert new List<AppError__c>{
            new AppError__c(txl_FullMailBody__c = mails[0]),
            new AppError__c(txl_FullMailBody__c = mails[1])
        };


        // Exercise
        Test.startTest();

        ArchiveRecords command = new ArchiveRecords(AppError__c.SObjectType, ArchivedAppError__b.SObjectType, '');
        command.execute();

        Test.stopTest();


        // Verify
        System.assertEquals(2, command.archived.size());
        System.assertEquals(2, command.deleted.size());
    }


    // HELPER

    private static void setup() {
        account = new Account_t();
        app = new LmaPackage().name('App A').ns('NSA');
        version = new LmaVersion(app).name('v1');
        license = new LmaLicense(account, version).org('00D000000000001');
        account.persist();

        StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = 'error_mails_txt'];
        mails = resource.Body.toString().split('&');
        System.assert(!mails.isEmpty());
    }
}