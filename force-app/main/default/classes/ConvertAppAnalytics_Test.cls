@IsTest
private class ConvertAppAnalytics_Test {

    private static final String CSV = [SELECT Body FROM StaticResource WHERE Name = 'error_logs_csv'].Body.toString();

    @IsTest
    private static void execute() {

        // Setup
        // Note: Take the fake ids in the Static Resource CSV
        new LmaPackage().id('0333h000000HNlV')
            .add(new LmaVersion().id('04t1R000001MSgE'))
            .persist();
        

        // Exercise 
        new ConvertAppAnalytics(CSV).execute();


        // Verify
        List<AppError__c> errors = [SELECT dtm_RecordedDate__c, txt_OrgId__c, txt_ApexClass__c, txt_Method__c, lkp_Package__c, lkp_PackageVersion__c, txt_ExceptionType__c FROM AppError__c];
        System.assert(!errors.isEmpty());

        for(AppError__c error : errors) {
            System.assertNotEquals(null, error.dtm_RecordedDate__c, '' + error);
            System.assert(String.isNotBlank(error.txt_OrgId__c), '' + error);
            System.assert(String.isNotBlank(error.txt_ApexClass__c), '' + error);
            System.assert(String.isNotBlank(error.txt_Method__c), '' + error);
            System.assert(String.isNotBlank(error.lkp_Package__c), '' + error);
            System.assert(String.isNotBlank(error.lkp_PackageVersion__c), '' + error);
            System.assert(String.isNotBlank(error.txt_ExceptionType__c), '' + error);
            // TODO: Add more
        }
    }


    @IsTest
    private static void parse() {

        // Exercise
        List<Map<String, String>> parsed = ConvertAppAnalytics.parse(CSV);


        // Verify
        System.assert(!parsed.isEmpty());
    }
}