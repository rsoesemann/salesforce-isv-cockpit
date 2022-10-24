@IsTest
private class NotifySlackChannel_Test {

    private static Slack.App app;
    private static Slack.TestHarness harness;
    private static Slack.TestHarness.State state;
    private static Slack.TestHarness.UserSession session;

    
    @IsTest
    private static void sendsMessageToChannelOnAppError() {
        
        // Setup
        setupSlack();

        
        // Exercise
        Test.startTest();
        
        new AppError().persist();
        
        Test.stopTest();


        // Verify
        System.assertEquals(1, session.getMessages().size());

        Slack.TestHarness.Message message = session.getMessages()[0];
        Slack.TestHarness.Header header = (Slack.TestHarness.Header) message.getComponent(0, Slack.TestHarness.Header.class);
        System.assertEquals('ALERT: New App Error has been created.', header.getText());
    }


    // HELPER

    private static void setupSlack() {
        insert new Settings__c(txt_SlackChannel__c = 'Cxxxxxx', txt_SlackTeam__c = 'Txcxxcx');

        app = Slack.App.IsvCockpit.get();
        harness = new Slack.TestHarness();
        state = harness.getNewSlackState();
        session = state.createUserSession();
    }
}