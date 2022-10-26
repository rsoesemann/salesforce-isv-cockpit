@IsTest
private class NotifySlackChannel_Test {

    @IsTest
    private static void onNewAppError() {
        
        // Setup
        Slack.TestHarness.State state = new Slack.TestHarness().getNewSlackState();
        Slack.TestHarness.Team team = state.createTeam('any');
        Slack.TestHarness.Channel channel = state.createPublicChannel(team, 'any');
        Slack.TestHarness.UserSession session = state.createUserSession();

        insert new Settings__c(txt_SlackTeam__c = team.getId(), txt_SlackChannel__c = channel.getId());
        
        // Exercise
        Test.startTest();
        new AppError().persist();
        Test.stopTest();


        // Verify
        System.assertEquals(1, session.getMessages().size());
    }
}
