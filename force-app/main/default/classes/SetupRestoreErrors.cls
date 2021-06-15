public with sharing class SetupRestoreErrors extends SetupStep {

    public String filter { get; set; }


    // CONSTRUCTOR

    public SetupRestoreErrors() {
        filter = 'dtm_ArchivedDate__c < LAST_N_DAYS:2';
    }


    // PUBLIC

    public override ApexPages.Message getStatus() {
        String status = new AsyncSoql().status();

        return (status == null) 
                ? new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to restore as another Restore is in Status :' + status)
                : new ApexPages.Message(ApexPages.Severity.INFO, 'Specify an <a href="https://developer.salesforce.com/docs/atlas.en-us.bigobjects.meta/bigobjects/async_query_overview.htm">Async SOQL filter criteria</a> to restore archived errors from Big Objects into the original data model.');
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
        public String targetObject;
        public Map<String, String> targetFieldMap = new Map<String, String>();

        // CONSTRUCTOR

        private AsyncSoql() {}

        private AsyncSoql(SObjectType sourceType, SObjectType targetType, String filter) {
            targetObject = '' + targetType;

            CorrespondingFields mapping = new CorrespondingFields(sourceType, targetType);
            for(SObjectField target : mapping.targetFields()) {
                SObjectField source = mapping.sourceField(target);

                targetFieldMap.put('' + source, '' + target);
            }
            
            query = String.format('SELECT {0} FROM {1}', 
                                  new List<String>{ String.join(new List<String>(targetFieldMap.keySet()), ','), '' + sourceType });

            if(String.isNotBlank(filter)){
                query += ' WHERE ' + String.escapeSingleQuotes(filter);       
            }                                                                    
        }


        private void query() {
            AsyncQuery result = (AsyncQuery) JSON.deserialize(callout(this), AsyncQuery.class);
            handleErrors(result);
        }


        private String status() {
            String result = null;

            AsyncQueryCollection response = (AsyncQueryCollection) JSON.deserialize(callout(null), AsyncQueryCollection.class);
            for(AsyncQuery query : response.asyncQueries) {
                handleErrors(query);
                result = query.status;
            }
            
            return result;
        }


        private String callout(Object body) {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/v51.0/async-queries/');
            request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
            request.setHeader('Content-Type', 'application/json');
            request.setMethod('GET');

            if(body != null) {
                request.setMethod('POST');
                request.setBody( JSON.serialize(body) );
            }

            String result = new Http().send(request).getBody();
System.debug(LoggingLevel.ERROR, result);
            return result;
        }


        private AsyncQuery handleErrors(AsyncQuery query) {
            if(query.errorCode != null) {
                throw new ApplicationException('AsyncSOQL failed: (' + query.errorCode + ') ' + query.message);
            }
            
            return query;
        }
    }


    private class AsyncQueryCollection {
        public List<AsyncQuery> asyncQueries;
    }

    private class AsyncQuery {
        public Id jobId;
        public String status;
        public String errorCode;
        public String message;
    }
}