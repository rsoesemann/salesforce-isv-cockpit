public with sharing class NotifySlackChannel  {

    private List<SObject> records;

    // CTOR

    public NotifySlackChannel(List<SObject> records) {
        this.records = records;
    }


    // PUBLIC

    public void execute() {
        Settings__c settings = Settings__c.getOrgDefaults();

        if (settings != null || settings.txt_SlackChannel__c != null || settings.txt_SlackTeam__c != null ) {
            Slack.App app = Slack.App.IsvCockpit.get();
        
            Slack.BotClient botClient = app.getBotClientForTeam(settings.txt_SlackTeam__c);

            for(SObject record : records) {
                Slack.ViewReference view = Slack.View.recordNotification.get();
                view.setParameter('header', 'ALERT: New ' + record.getSObjectType().getDescribe().getLabel() + ' has been created.');
                view.setParameter('recordId', record.Id);
                view.setParameter('recordLink', URL.getSalesforceBaseUrl().toExternalForm() + '/' + record.Id);

                Slack.ChatPostMessageRequest request = new Slack.ChatPostMessageRequest.builder()
                    .channel(settings.txt_SlackChannel__c)
                    .viewReference(view)
                    .build();

                Slack.ChatPostMessageResponse response = botclient.chatPostMessage(request);
                if(!response.isOk()) {
                    throw new ApplicationException(response.getError());
                }
            }
        }
    }
}