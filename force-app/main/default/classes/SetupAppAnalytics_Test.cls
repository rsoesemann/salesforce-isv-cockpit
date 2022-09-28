@IsTest
private class SetupAppAnalytics_Test {

    @IsTest
    private static void execute() {
        
        // Setup
        sfLma__Package__c p = (sfLma__Package__c) new LmaPackage().ns('any').persist();

        SetupAppAnalytics step = new SetupAppAnalytics();
        System.assertEquals(ApexPages.Severity.WARNING, step.getStatus().getSeverity());


        // Exercise
        Test.startTest();
        step.run();
        Test.stopTest();


        // Verify
        System.assertEquals(p.sfLma__Package_ID__c, SetupAppAnalytics.request.PackageIds);

        step = new SetupAppAnalytics();
        System.assertEquals(ApexPages.Severity.CONFIRM, step.getStatus().getSeverity());
    }
}