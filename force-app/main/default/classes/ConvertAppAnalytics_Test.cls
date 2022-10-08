@IsTest
private class ConvertAppAnalytics_Test {

    private static final String CSV = [SELECT Body FROM StaticResource WHERE Name = 'record_logs_csv'].Body.toString();

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
        List<PackageUsageSummary__c> summaries = [SELECT txt_CustomEntity__c, txt_CustomEntityType__c, txt_ManagedPackageNamespace__c, txt_Month__c,  
                                                        num_Creates__c, num_Deletes__c, num_Reads__c, num_Updates__c, num_Views__c, ext_OrganizationId__c, ext_PackageId__c, txt_UserIdToken__c, txt_UserType__c
                                                 FROM PackageUsageSummary__c];
        System.assert(!summaries.isEmpty());

        for(PackageUsageSummary__c record : summaries) {
            System.assert(String.isNotBlank(record.txt_CustomEntity__c), '' + record);
            System.assert(String.isNotBlank(record.txt_CustomEntityType__c), '' + record);
            System.assert(String.isNotBlank(record.txt_ManagedPackageNamespace__c), '' + record);
            System.assert(String.isNotBlank(record.txt_Month__c), '' + record);
            System.assertNotEquals(null, record.num_Creates__c);
            System.assertNotEquals(null, record.num_Deletes__c);
            System.assertNotEquals(null, record.num_Reads__c);
            System.assertNotEquals(null, record.num_Updates__c);
            System.assertNotEquals(null, record.num_Views__c);
            System.assert(String.isNotBlank(record.ext_OrganizationId__c), '' + record);
            System.assert(String.isNotBlank(record.ext_PackageId__c), '' + record);
            System.assert(String.isNotBlank(record.txt_UserIdToken__c), '' + record);
            System.assert(String.isNotBlank(record.txt_UserType__c), '' + record);
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