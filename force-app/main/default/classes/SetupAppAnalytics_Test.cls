@IsTest
private class SetupAppAnalytics_Test {

    @IsTest
    private static void execute() {
        
        // Setup
        sfLma__Package__c p = (sfLma__Package__c) new LmaPackage().persist();

        SetupAppAnalytics step = new SetupAppAnalytics();
        System.assertEquals(ApexPages.Severity.WARNING, step.getStatus().getSeverity());


        // Verify
        Test.startTest();
        step.run();
        Test.stopTest();


        // Exercise
        AppAnalyticsQueryRequest request = [SELECT PackageIds FROM AppAnalyticsQueryRequest LIMIT 1];
        System.assertEquals(p.sfLma__Package_ID__c, request.PackageIds);
    }
}
