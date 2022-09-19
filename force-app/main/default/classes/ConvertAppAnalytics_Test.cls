@IsTest
private class ConvertAppAnalytics_Test {

    private static final String CSV = [SELECT Body FROM StaticResource WHERE Name = 'error_logs_csv'].Body.toString();

    @IsTest
    private static void execute() {
        
        // Exercise 
        new ConvertAppAnalytics(CSV).execute();


        // Verify
        List<AppError__c> errors = [SELECT dtm_RecordedDate__c, txt_OrgId__c, txt_ApexClass__c, lkp_Package__c, lkp_PackageVersion__c, txt_ExceptionType__c FROM AppError__c];
        System.assert(!errors.isEmpty());

        for(AppError__c error : errors) {
            System.assertNotEquals(null, error.dtm_RecordedDate__c, '' + error);
            System.assert(String.isNotBlank(error.txt_OrgId__c), '' + error);
            System.assert(String.isNotBlank(error.txt_ApexClass__c), '' + error);
            System.assert(String.isNotBlank(error.lkp_Package__c), '' + error);
            System.assert(String.isNotBlank(error.lkp_PackageVersion__c), '' + error);
            System.assert(String.isNotBlank(error.txt_ExceptionType__c), '' + error);
        }
    }


    @IsTest
    private static void parse() {

        // Exercise
        List<Map<String, String>> parsed = ConvertAppAnalytics.parse(CSV);


        // Verify
        System.assert(!parsed.isEmpty());
    }


    @IsTest
    private static void parseHeader() {

        // Exercise
        Map<Integer, String> header = ConvertAppAnalytics.parseHeader(CSV.split('\n')[0]);


        // Verify
        System.assert(!header.isEmpty());
        System.assertEquals('timestamp_derived' ,header.get(0));
        System.assertEquals('organization_id' ,header.get(1));
        System.assertEquals('user_id_token' ,header.get(2));
        System.assertEquals('package_id' ,header.get(3));
        System.assertEquals('package_version_id' ,header.get(4));
        System.assertEquals('managed_package_namespace' ,header.get(5));
        System.assertEquals('page_url' ,header.get(6));
        System.assertEquals('class_name' ,header.get(7));
        System.assertEquals('method_name' ,header.get(8));
        System.assertEquals('stack_trace' ,header.get(9));
    }
}