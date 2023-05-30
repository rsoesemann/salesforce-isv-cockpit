public with sharing class AddErrorInsights {

    // PUBLIC

    @InvocableMethod(label = 'Add Error Insights from OpenAI')
    public static void execute(List<Id> errorIds) {
        List<AppError__c> errors = [SELECT txl_FullMailBody__c FROM AppError__c 
                                    WHERE Id IN :errorIds WITH SYSTEM_MODE];

        for(AppError__c error : errors) {
            error.txl_Hints__c = execute(error);
        }

        update as system errors;
    }


    // PRIVATE

    private static String execute(AppError__c error) {
        HttpResponse result = null;

        try {
            result = new Http().send(openAiRequestFor(error));

            if(result.getStatusCode() != 200) {
                throw new ApplicationException('Error: ' + result.getStatus());
            }
        } 
        catch(Exception ex) {
            throw new ApplicationException('Error: ' + ex.getMessage());
        }

        return OpenAiCompletions.response(result.getBody()).choices[0].message.content;
    }


    private static HttpRequest openAiRequestFor(AppError__c error) {
        HttpRequest result = new HttpRequest();
        result.setEndpoint('https://api.openai.com/v1/chat/completions');
        result.setMethod('POST');
        result.setHeader('Content-Type', 'application/json');
        result.setHeader('Authorization', 'Bearer ' + openAiApiKey());
        result.setTimeout(120000);
        result.setBody( new OpenAiCompletions.Request()
                                .model('gpt-4')
                                .message(new OpenAiCompletions.Message()
                                                .role('system')
                                                .content('You are an experienced Salesforce Developer of a Managed Package.'))
                                .message(new OpenAiCompletions.Message()
                                                .role('user')
                                                .content('You received the following automated error email from one of my subscriber orgs. What does it mean? \n\n' + error.txl_FullMailBody__c))
                                .asJson() );
        return result;
    }


    private static String openAiApiKey() {
        Settings__c result = Settings__c.getOrgDefaults();
        
        if(result == null || result.txt_OpenAiApiKey__c == null ) {
            throw new ApplicationException('No OpenAI API Key found in Settings.');
        }

        return result.txt_OpenAiApiKey__c;
    }
}