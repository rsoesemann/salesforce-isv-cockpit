@IsTest
private class ParseAppErrors_Test {

    private static Account_t account;
    private static LmaPackage app;
    private static LmaVersion version;
    private static LmaLicense license;
    private static List<String> mails;


    @IsTest
    private static void pageError() {

        // Setup
        setup();

        AppError__c e = new AppError__c(txl_FullMailBody__c = mails[0]);


        // Exercise
        new ParseAppErrors(e).execute();


        // Verify
        System.assertEquals('005500000024uNj', e.txt_UserId__c);
        System.assertEquals('00D000000000001', e.txt_OrgId__c);
        System.assertEquals('NSA', e.txt_Namespace__c);
        System.assertEquals('System.NullPointerException', e.txt_ExceptionType__c);
        System.assertEquals('Attempt to de-reference a null object', e.txt_ExceptionMessage__c);
        System.assertEquals('MyController', e.txt_ApexClass__c);
        System.assertEquals('myPage', e.txt_VisualforcePage__c);
    }


    @IsTest
    private static void triggerError() {

        // Setup
        setup();

        AppError__c e = new AppError__c(txl_FullMailBody__c = mails[1]);


        // Exercise
        new ParseAppErrors(e).execute();


        // Verify
        System.assertEquals('005500000024uNj', e.txt_UserId__c);
        System.assertEquals('00D000000000001', e.txt_OrgId__c);
        System.assertEquals('NSA', e.txt_Namespace__c);
        System.assertEquals('System.DmlException', e.txt_ExceptionType__c);
        System.assertEquals('Delete failed. First exception on row 0 with id a031t00000RuMxyAAF; first error: ENTITY_IS_DELETED, entity is deleted: []', e.txt_ExceptionMessage__c);
        System.assertEquals('TriggerDelete', e.txt_ApexClass__c);
        System.assertEquals(null, e.txt_VisualforcePage__c);
    }


    @IsTest
    private static void batchError() {

        // Setup
        setup();

        AppError__c e = new AppError__c(txl_FullMailBody__c = mails[2]);


        // Exercise
        new ParseAppErrors(e).execute();


        // Verify
        System.assertEquals('005500000024uNj', e.txt_UserId__c);
        System.assertEquals('00D000000000001', e.txt_OrgId__c);
        System.assertEquals('NSA', e.txt_Namespace__c);
        System.assertEquals('System.DmlException', e.txt_ExceptionType__c);
        System.assertEquals('Insert failed. First exception on row 0; first error: STRING_TOO_LONG, Log Status: Datenwert zu groß: Fehler NSA.RetrieveAction.UnsuccessfulCalloutException (max length=80): [Name]', e.txt_ExceptionMessage__c);
        System.assertEquals('IteratorImpl', e.txt_ApexClass__c);
        System.assertEquals(null, e.txt_VisualforcePage__c);
    }


    @IsTest
    private static void linkToLma(){

        // Setup
        setup();

        LmaPackage otherApp = new LmaPackage().name('App B').ns('NSB');
        LmaVersion otherVersion = new LmaVersion(otherApp).name('v2');
        new LmaLicense(account, otherVersion)
                .org('00D000000000001')
                .persist();

        AppError__c e = new AppError__c(txl_FullMailBody__c = mails[1]);


        // Exercise
        new ParseAppErrors(e).execute();


        // Verify
        System.assertEquals(account.Id, e.lkp_Account__c);
        System.assertEquals(license.Id, e.lkp_License__c);
        System.assertEquals(app.Id, e.lkp_Package__c);
        System.assertEquals(version.Id, e.lkp_PackageVersion__c);
    }


    @IsTest
    private static void reparseOnChange(){

        // Setup
        setup();

        AppError__c e = new AppError__c(txl_FullMailBody__c = mails[0]);
        insert e;


        // Exercise
        e.txl_FullMailBody__c = e.txl_FullMailBody__c.replaceAll('NSA.MyController', 'NSA.MyOtherController');
        update e;

        
        // Verify
        System.assertEquals('MyOtherController' , [SELECT txt_ApexClass__c FROM AppError__c LIMIT 1].txt_ApexClass__c);
    }


    @IsTest
    private static void realWorldErrors() {

        // Setup
        setup();

        List<AppError__c> errors = new List<AppError__c>();
        for(String mail : mails) {
            errors.add(new AppError__c(txl_FullMailBody__c = mail));
        }


        // Exercise
        Test.startTest();
            new ParseAppErrors(errors).execute();
        Test.stopTest();


        // Verify
        Integer index = 1;
        for(AppError__c e : query()) {
            String message = 'Failed on error ' + index++ + ' ' + e.txl_FullMailBody__c;
            System.assertNotEquals(null, e.txt_OrgId__c, message);
            System.assertNotEquals(null, e.txt_UserId__c, message);
            System.assertNotEquals(null, e.txt_Namespace__c, message);
            System.assertNotEquals(null, e.txt_ApexClass__c, message);
            System.assertNotEquals(null, e.txt_ExceptionType__c, message);
            System.assertNotEquals(null, e.txt_ExceptionMessage__c, message);
        }
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


    private static List<AppError__c> query() {
        return [SELECT txt_UserId__c, txt_OrgId__c, txt_Namespace__c, txt_ExceptionType__c, txt_ExceptionMessage__c,
                lkp_Account__c, txt_ApexClass__c, txt_VisualforcePage__c, txl_Stacktrace__c, lkp_License__c, lkp_Package__c,
                lkp_PackageVersion__c, txl_FullMailBody__c FROM AppError__c];
    }


    private static AppError__c error(DateTime dt) {
        return new AppError__c(dtm_RecordedDate__c = dt);
    }
}