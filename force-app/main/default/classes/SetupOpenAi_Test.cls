@IsTest
private class SetupOpenAi_Test {
        
    @IsTest
    private static void createSettings() {
        
        // Setup
        Test.setCurrentPage(Page.setup);
        SetupOpenAi step = new SetupOpenAi();

        System.assertEquals(ApexPages.Severity.WARNING, step.getStatus().getSeverity());


        // Exercise
        step.settings.txt_OpenAiApiKey__c = 'sk-asfsdGZUJHFZJHFVasdfyxdc';
        step.run();
        


        // Verify
        System.assertEquals(ApexPages.Severity.CONFIRM, step.getStatus().getSeverity());

        Settings__c settings = [SELECT txt_OpenAiApiKey__c FROM Settings__c LIMIT 1];
        System.assertEquals(step.settings.txt_OpenAiApiKey__c, settings.txt_OpenAiApiKey__c);

    }
        

    @IsTest
    private static void changeSettings() {
        
        // Setup
        insert new Settings__c();

        Test.setCurrentPage(Page.setup);
        SetupOpenAi step = new SetupOpenAi();

        System.assertEquals(ApexPages.Severity.WARNING, step.getStatus().getSeverity());


        step.settings.txt_OpenAiApiKey__c = 'aefxdsbxfx2345543dsfg';
        step.run();


        // Verify
        System.assertEquals(ApexPages.Severity.CONFIRM, step.getStatus().getSeverity());
    }
}