public with sharing class OnSlackEvent extends Slack.EventDispatcher {

    public override Slack.ActionHandler invoke(Slack.EventParameters parameters, Slack.RequestContext context) {
          return Slack.ActionHandler.ack(new Handler(parameters, context));
      }
  
    public class Handler implements Slack.RunnableHandler {
        Slack.EventParameters parameters;
        Slack.RequestContext context;
  
        public Handler(Slack.EventParameters parameters, Slack.RequestContext context) {
            this.parameters = parameters;
            this.context = context;
        }
    
        public void run() {
            SetupSlack setup = new SetupSlack();
            Settings__c settings = setup.settings;
System.debug(LoggingLevel.ERROR, parameters.getEvent());
            Set<String> channels = new Set<String>(settings.txt_SlackChannel__c.split('\\s*,\\s*'));
            if( channels.add(context.getChannelId()) ) {
                settings.txt_SlackChannel__c = String.join(new List<String>( channels), ',');
                settings.txt_SlackTeam__c = context.getTeamId();
                setup.run();
System.debug(LoggingLevel.ERROR, settings);
                Slack.ChatPostMessageRequest messageRequest = new Slack.ChatPostMessageRequest.builder()
                            .channel(context.getChannelId())
                            .text('Salesforce ISV Cockpit will send notifications to this channel')
                            .build();

                Slack.App.IsvCockpit.get()
                            .getBotClientForTeam(context.getTeamId())
                            .chatPostMessage(messageRequest);
            }
        }
    }
}