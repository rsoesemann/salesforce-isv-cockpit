@IsTest
private class ParseAppErrors_Test {

    private static Account_t customer;
    private static LmaPackage appA;
    private static LmaPackage appB;
    private static LmaVersion verA;
    private static LmaVersion verB;
    private static LmaLicense licA;
    private static LmaLicense licB;

    private static List<String> mails;


    @IsTest
    private static void triggerError(){

        // Setup
        setup();

        System.debug(LoggingLevel.ERROR, [SELECT sfLma__Subscriber_Org_ID__c, sfLma__Package__r.txt_Namespace__c, sfLma__Package_Version__c, sfLma__Account__c
        FROM sflma__License__c WHERE sfLma__Package__r.txt_Namespace__c = 'NSA' AND sfLma__Subscriber_Org_ID__c = '00D000000000000']);


        // Exercise
        insert new AppError__c(txl_FullMailBody__c = mails[0]);


        // Verify
        AppError__c e = query()[0];
        System.assertEquals('005500000024uNj' , e.txt_UserId__c );
        System.assertEquals('00D000000000001' , e.txt_OrgId__c );
        System.assertEquals('NSA.MyClass', e.txt_Location__c);
        System.assertEquals('NSA', e.txt_Namespace__c);
        System.assertEquals('System.LimitException' , e.txt_ExceptionType__c);
        System.assertEquals('Apex CPU time limit exceeded' , e.txt_ExceptionMessage__c);
        System.assertEquals('MyClass' , e.txt_ApexClass__c);
        System.assertEquals(null, e.txt_VisualforcePage__c);
        System.assertEquals(appA.Id, e.lkp_Package__c);
        System.assertEquals(verA.Id, e.lkp_PackageVersion__c);
        System.assertEquals(licA.Id, e.lkp_License__c);
        System.assertEquals(customer.Id, e.lkp_Account__c);
    }


    @IsTest
    private static void visualforceError() {

        // Setup
        setup();


        // Exercise
        insert new AppError__c(txl_FullMailBody__c = mails[1]);


        // Verify
        AppError__c e = query()[0];
        System.assertEquals('005500000024uNj', e.txt_UserId__c);
        System.assertEquals('00D000000000001', e.txt_OrgId__c);
        System.assertEquals('NSB', e.txt_Namespace__c);
        System.assertEquals('System.NullPointerException', e.txt_ExceptionType__c);
        System.assertEquals('Attempt to de-reference a null object', e.txt_ExceptionMessage__c);
        System.assertEquals('NSB.MyController', e.txt_ApexClass__c);
        System.assertEquals('myPage', e.txt_VisualforcePage__c);
        System.assertEquals('NSB.MyController.createSelectOptions: line 143, column 1', e.txt_Location__c);
        System.assertEquals(appB.Id, e.lkp_Package__c);
        System.assertEquals(verB.Id, e.lkp_PackageVersion__c);
        System.assertEquals(licB.Id, e.lkp_License__c);
        System.assertEquals(customer.Id, e.lkp_Account__c);
    }


    private static void reparseOnChange(){

        // Setup
        setup();

        AppError__c e = new AppError__c(txl_FullMailBody__c = mails[0]);
        insert e;


        // Exercise
        e.txl_FullMailBody__c.replaceAll('MyClass', 'MyOtherClass');
        update e;

        
        // Verify
        System.assertEquals('MyOtherClass' , e.txt_ApexClass__c);
    }


    @IsTest
    private static void realWorldErrors() {

        // Setup
        setup();


        // Exercise
        List<AppError__c> errors = new List<AppError__c>();
        for(String mail : mails) {
            errors.add(new AppError__c(txl_FullMailBody__c = mail));
        }
        insert errors;


        // Verify
        for(AppError__c e : query()) {
            System.assert(ParseAppErrors.isPopulated(e), ''+e);
        }
    }


    // HELPER

    private static void setup() {
        customer = new Account_t();

        appA = new LmaPackage().name('App A').ns('NSA');
        verA = new LmaVersion(appA).name('v1');
        licA = new LmaLicense(customer, verA).org('00D000000000001');

        appB = new LmaPackage().name('App B').ns('NSB');
        verB = new LmaVersion(appB).name('v1');
        licB = new LmaLicense(customer, verB).org('00D000000000001');

        customer.persist();

        StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = 'error_mails_txt'];
        mails = resource.Body.toString().split('&');
        System.assert(!mails.isEmpty());
    }


    private static List<AppError__c> query() {
        return [SELECT txt_UserId__c, txt_OrgId__c, txt_Namespace__c, txt_ExceptionType__c, txt_ExceptionMessage__c,
                        lkp_Account__c, txt_ApexClass__c, txt_VisualforcePage__c, txt_Location__c, lkp_License__c, lkp_Package__c, lkp_PackageVersion__c
                FROM AppError__c];
    }
}