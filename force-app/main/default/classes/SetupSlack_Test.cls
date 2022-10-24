@IsTest
private class SetupSlack_Test {
        
    @IsTest
    private static void createSettings() {
        
        // Setup
        Test.setCurrentPage(Page.setup);
        SetupSlack step = new SetupSlack();

        System.assertEquals(ApexPages.Severity.WARNING, step.getStatus().getSeverity());


        // Exercise
        step.settings.txt_SlackTeam__c = 'Txxxx';
        step.settings.txt_SlackChannel__c = 'Cxxxxcx';
        step.run();
        


        // Verify
        System.assertEquals(ApexPages.Severity.CONFIRM, step.getStatus().getSeverity());

        Settings__c settings = [SELECT txt_SlackTeam__c, txt_SlackChannel__c FROM Settings__c LIMIT 1];
        System.assertEquals(step.settings.txt_SlackTeam__c, settings.txt_SlackTeam__c);
        System.assertEquals(step.settings.txt_SlackChannel__c, settings.txt_SlackChannel__c);

    }
        

    @IsTest
    private static void changeSettings() {
        
        // Setup
        insert new Settings__c(txt_SlackTeam__c = 'Txxxxxx');

        Test.setCurrentPage(Page.setup);
        SetupSlack step = new SetupSlack();

        System.assertEquals(ApexPages.Severity.WARNING, step.getStatus().getSeverity());
        System.assertEquals('Txxxxxx', step.settings.txt_SlackTeam__c);


        // Exercise
        step.settings.txt_SlackChannel__c = 'Cxxxxcx';
        step.run();


        // Verify
        System.assertEquals(ApexPages.Severity.CONFIRM, step.getStatus().getSeverity());
    }
        

    @IsTest
    private static void incompleteSettings() {
        
        // Setup
        Settings__c settings = new Settings__c(txt_SlackTeam__c = 'Txxxxxx');
        insert settings;


        // Exercise
        new SetupSlack().run();


        // Verify
        settings = [SELECT CreatedDate, LastModifiedDate FROM Settings__c LIMIT 1];
        System.assertEquals(settings.CreatedDate, settings.LastModifiedDate);
    }
}