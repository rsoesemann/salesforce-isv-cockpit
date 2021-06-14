public with sharing class SetupRestoreErrors extends SetupStep {

    public String filter { get; set; }


    // CONSTRUCTOR

    public SetupRestoreErrors() {
        filter = 'dtm_ArchivedDate__c < LAST_N_DAYS:2';
    }


    // PUBLIC

    public override ApexPages.Message getStatus() {
        String message = 'Specify an <a href="https://developer.salesforce.com/docs/atlas.en-us.bigobjects.meta/bigobjects/async_query_overview.htm">Async SOQL filter criteria</a> to restore archived errors from Big Objects into the original data model.';
        return new ApexPages.Message(ApexPages.Severity.INFO, message);
    }


    public override PageReference run() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/v51.0/async-queries');
        request.setMethod('POST');
        request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        request.setHeader('Content-Type', 'application/json');
        request.setBody( new AsyncSoql(AppErrorArchived__b.SObjectType, AppError__c.SObjectType, filter)
                                .serialized() );

        new Http().send(request);

        return currentPage();
    }


    public override Boolean getShowButtonOnSuccess() {
        return true;
    }


    public override String buttonLabel() {
        return 'Execute';
    }


    // INNER

   private class AsyncSoql {

        public String query;
        public SObjectType targetType;
        public Map<String, String> targetFieldMap = new Map<String, String>();

        private AsyncSoql(SObjectType sourceType, SObjectType targetType, String filter) {
            this.targetType = targetType;

            CorrespondingFields mapping = new CorrespondingFields(sourceType, targetType);
            for(SObjectField target : mapping.targetFields()) {
                SObjectField source = mapping.sourceField(target);
                targetFieldMap.put('' + source, '' + target);
            }
            
            query = String.format('SELECT {0} FROM {1} WHERE {2}', new List<String>{
                String.join(new List<String>(targetFieldMap.keySet()), ','),
                '' + sourceType, 
                String.escapeSingleQuotes(filter)
            });
        }

        private String serialized() {
            return JSON.serialize(this);
        }
   }
}