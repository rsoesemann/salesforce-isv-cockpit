@IsTest
private class ParseAppErrors_Test {

    private static Account_t account;
    private static LmaPackage app;
    private static LmaVersion version;
    private static LmaLicense license;
    private static List<String> mails;


    @IsTest
    private static void pageErrorFormat() {

        // Setup
        setup();


        // Exercise
        AppError__c e = new AppError__c(txl_FullMailBody__c = mails[0]);
        insert e;


        // Verify
        e = query()[0];
        System.assertEquals('005500000024uNj', e.txt_UserId__c);
        System.assertEquals('00D000000000001', e.txt_OrgId__c);
        System.assertEquals('NSB', e.txt_Namespace__c);
        System.assertEquals('System.NullPointerException', e.txt_ExceptionType__c);
        System.assertEquals('Attempt to de-reference a null object', e.txt_ExceptionMessage__c);
        System.assertEquals('NSB.MyController', e.txt_ApexClass__c);
        System.assertEquals('myPage', e.txt_VisualforcePage__c);
        System.assertEquals('PageErrorFormat', e.txt_MatchedWith__c);
    }


    @IsTest
    private static void triggerErrorFormat() {

        // Setup
        setup();


        // Exercise
        AppError__c e = new AppError__c(txl_FullMailBody__c = mails[1]);
        insert e;


        // Verify
        e = query()[0];
        System.assertEquals('005500000024uNj', e.txt_UserId__c);
        System.assertEquals('00D000000000001', e.txt_OrgId__c);
        System.assertEquals('NSA', e.txt_Namespace__c);
        System.assertEquals('System.DmlException', e.txt_ExceptionType__c);
        System.assertEquals('Delete failed. First exception on row 0 with id a031t00000RuMxyAAF; first error: ENTITY_IS_DELETED, entity is deleted: []', e.txt_ExceptionMessage__c);
        System.assertEquals('TriggerDelete', e.txt_ApexClass__c);
        System.assertEquals(null, e.txt_VisualforcePage__c);
        System.assertEquals('TriggerErrorFormat', e.txt_MatchedWith__c);
    }


    @IsTest
    private static void batchErrorFormat() {

        // Setup
        setup();


        // Exercise
        AppError__c e = new AppError__c(txl_FullMailBody__c = mails[2]);
        insert e;


        // Verify
        e = query()[0];
        System.assertEquals('005500000024uNj', e.txt_UserId__c);
        System.assertEquals('00D000000000001', e.txt_OrgId__c);
        System.assertEquals('NSA', e.txt_Namespace__c);
        System.assertEquals('System.DmlException', e.txt_ExceptionType__c);
        System.assertEquals('Insert failed. First exception on row 0; first error: STRING_TOO_LONG, Log Status: Datenwert zu groß: Fehler NSA.RetrieveAction.UnsuccessfulCalloutException (max length=80): [Name]', e.txt_ExceptionMessage__c);
        System.assertEquals('IteratorImpl', e.txt_ApexClass__c);
        System.assertEquals(null, e.txt_VisualforcePage__c);
        System.assertEquals('BatchErrorFormat', e.txt_MatchedWith__c);
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


        // Exercise
        insert new AppError__c(txl_FullMailBody__c = mails[1]);


        // Verify
        AppError__c e = query()[0];
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
        e.txl_FullMailBody__c = e.txl_FullMailBody__c.replaceAll('NSB.MyController', 'NSB.MyOtherController');
        update e;

        
        // Verify
        System.assertEquals('NSB.MyOtherController' , [SELECT txt_ApexClass__c FROM AppError__c LIMIT 1].txt_ApexClass__c);
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
            insert errors;
        Test.stopTest();


        // Verify
        for(AppError__c e : query()) {
            System.assertNotEquals(null, e.txt_MatchedWith__c, e.txl_FullMailBody__c);
            
            System.assertNotEquals(null, e.txt_OrgId__c, e.txl_FullMailBody__c);
            System.assertNotEquals(null, e.txt_UserId__c, e.txl_FullMailBody__c);
            System.assertNotEquals(null, e.txt_Namespace__c, e.txl_FullMailBody__c);
            System.assertNotEquals(null, e.txt_ApexClass__c, e.txl_FullMailBody__c);
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
                lkp_PackageVersion__c, txt_MatchedWith__c, txl_FullMailBody__c FROM AppError__c];
    }
}