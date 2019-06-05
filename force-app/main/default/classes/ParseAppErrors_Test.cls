@IsTest
private class ParseAppErrors_Test {
    
    private static LmaPackage lmaPackage;
    private static LmaVersion lmaVersion;
    private static LmaLicense lmaLicense;
    private static List<String> mails;


    @IsTest
    private static void triggerError(){

        // Setup
        setup();


        // Exercise
        insert new AppError__c(txl_FullMailBody__c = mails[0]);


        // Verify
        AppError__c e = query()[0];
        System.assertEquals('005500000024uNj' , e.txt_UserId__c );
        System.assertEquals('00Dd0000000dsbB' , e.txt_OrgId__c );
        System.assertEquals('ACME.MyClass', e.txt_Location__c);
        System.assertEquals('ACME', e.txt_Namespace__c);
        System.assertEquals('System.LimitException' , e.txt_ExceptionType__c);
        System.assertEquals('Apex CPU time limit exceeded' , e.txt_ExceptionMessage__c);
        System.assertEquals('MyClass' , e.txt_ApexClass__c);
        System.assertEquals(null, e.txt_VisualforcePage__c);
        System.assertEquals(lmaLicense.Id, e.lkp_License__c);
        System.assertEquals(lmaPackage.Id, e.lkp_Package__c);
        System.assertEquals(lmaVersion.Id, e.lkp_PackageVersion__c);
    }


    @IsTest
    private static void visualforceError(){

        // Setup
        setup();


        // Exercise
        insert new AppError__c(txl_FullMailBody__c = mails[1]);


        // Verify
        AppError__c e = query()[0];
        System.assertEquals('005500000024uNj' , e.txt_UserId__c );
        System.assertEquals('00Dd0000000dsbB' , e.txt_OrgId__c );
        System.assertEquals('ACME', e.txt_Namespace__c);
        System.assertEquals('System.NullPointerException' , e.txt_ExceptionType__c);
        System.assertEquals('Attempt to de-reference a null object' , e.txt_ExceptionMessage__c);
        System.assertEquals('ACME.MyController' , e.txt_ApexClass__c);
        System.assertEquals('myPage' , e.txt_VisualforcePage__c);
        System.assertEquals('ACME.MyController.createSelectOptions: line 143, column 1' , e.txt_Location__c);
        System.assertEquals(lmaLicense.Id, e.lkp_License__c);
        System.assertEquals(lmaPackage.Id, e.lkp_Package__c);
        System.assertEquals(lmaVersion.Id, e.lkp_PackageVersion__c);
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
            System.assert(isPopulated(e), ''+e);
        }
    }


    // HELPER

    private static void setup() {
        lmaPackage = new LmaPackage().ns('ACME');
        lmaVersion = new LmaVersion(lmaPackage);
        lmaLicense = new LmaLicense(lmaVersion).org('00Dd0000000dsbB');
        lmaLicense.persist();

        StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = 'error_mails_txt'];
        mails = resource.Body.toString().split('&');
        System.assert(!mails.isEmpty());
    }


    private static List<AppError__c> query() {
        return [SELECT txt_UserId__c, txt_OrgId__c, txt_Namespace__c, txt_ExceptionType__c, txt_ExceptionMessage__c,
                        txt_ApexClass__c, txt_VisualforcePage__c, txt_Location__c, lkp_License__c, lkp_Package__c, lkp_PackageVersion__c
                FROM AppError__c];
    }


    private static Boolean isPopulated(AppError__c record) {
        return (record.txt_UserId__c != null
                            && record.txt_OrgId__c != null
                            && record.txt_Namespace__c != null
                            && record.txt_ApexClass__c != null
                            && record.txt_Location__c != null
                            && record.txt_ExceptionMessage__c != null
                            && record.txt_ExceptionType__c != null
                            && record.lkp_License__c != null
                            && record.lkp_Package__c != null
                            && record.lkp_PackageVersion__c != null);
    }
}