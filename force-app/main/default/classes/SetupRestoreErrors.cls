public with sharing class SetupRestoreErrors extends SetupStep {

    public String filter { get; set; }


    // CONSTRUCTOR

    public SetupRestoreErrors() {
        filter = 'dtm_ArchivedDate__c < LAST_N_DAYS:2';
    }


    // PUBLIC

    public override ApexPages.Message getStatus() {
        String status = new AsyncSoql().status();

		if((new List<String>{ null, 'Complete' }).contains(status)) {
			return new ApexPages.Message(ApexPages.Severity.CONFIRM, 
                        'Specify an <a href="https://developer.salesforce.com/docs/atlas.en-us.bigobjects.meta/bigobjects/async_query_overview.htm">Async SOQL filter criteria</a> to restore archived errors from Big Objects into the original data model.');
		}
		else {
			return new ApexPages.Message(ApexPages.Severity.INFO, 'Restore that has been started is in Status :' + status);
		}
    }


    public override PageReference run() {
        new AsyncSoql(ArchivedAppError__b.SObjectType, AppError__c.SObjectType, filter).query();

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
        public String targetType;
        public Map<String, String> targetFieldMap = new Map<String, String>();

        // CONSTRUCTOR

        private AsyncSoql() {}

        private AsyncSoql(SObjectType sourceType, SObjectType targetType, String filter) {
            this.targetType = '' + targetType;

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

        private Id query() {
            return new JSONParse( callout(this) )
                            .get('asyncQueries.[0].jobId').getIdValue();
        }
    
        private String status() {
            return new JSONParse( callout(null) )
                            .get('status').getStringValue();
    
        }
    
        private String callout(Object body) {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/v51.0/async-queries/');
            request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
            request.setHeader('Content-Type', 'application/json');
            
            if(body != null) {
                request.setMethod('POST');
                request.setBody( JSON.serialize(body) );
            }
            else {
                request.setMethod('GET');
            }
    
            return new Http().send(request).getBody();
        }
   }
}