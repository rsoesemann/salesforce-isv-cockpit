@IsTest
private class SetupPackageNamespaces_Test {


    @IsTest
    private static void execute() {

        // Setup
        new HttpMock()
                .any('{"records":[{"NamespacePrefix":"MYNS"}]}', 200)
                .mock();

        new LmaPackage().ns(null).persist();

        System.runAs(Personas.appAdmin()) {
            
            // Exercise
            Test.startTest();
            SetupPackageNamespaces step = new SetupPackageNamespaces();
            System.assertEquals(ApexPages.Severity.WARNING.name(), step.getSeverity());

            step.run();
            Test.stopTest();


            // Verify
            step = new SetupPackageNamespaces();
            System.assertEquals(ApexPages.Severity.CONFIRM.name(), step.getSeverity());
        }

        System.assertEquals('MYNS', [SELECT txt_Namespace__c FROM sfLma__Package__c LIMIT 1].txt_Namespace__c);
    }


    @IsTest
    private static void executeFailsWhenNoAdmin() {

        // Setup
        Exception expectedException = null;

        new LmaPackage().ns(null).persist();


        // Exercise
        
        System.runAs(Personas.appUser()) {
            try {
                new SetupPackageNamespaces().run();
            }
            catch(Exception ex) {
                expectedException = ex;
            }
        }


        // Verify
        System.assertNotEquals(null, expectedException);
    }
}