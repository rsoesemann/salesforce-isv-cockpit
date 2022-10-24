@isTest
private class OnSlackEvent_Test {

    private static Slack.App app;
    private static Slack.TestHarness harness;
    private static Slack.TestHarness.State state;
    private static Slack.TestHarness.UserSession session;


    @IsTest
    private static void oAppHomeOpened() {

        // Setup 
        setupSlack();


        // Execute
        Slack.TestHarness.Home home = session.openAppHome(app);


        // Verify
        System.assertEquals(3, home.getComponentCount());
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