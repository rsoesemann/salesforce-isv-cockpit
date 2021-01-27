public abstract class SetupStep {

    // ABSTRACT

    public abstract ApexPages.Message getStatus();
    public abstract PageReference run();

    // PUBLIC

    public Boolean success {
        get {
            try {
                return (getStatus().getSeverity() == ApexPages.Severity.CONFIRM);
            }
            catch(Exception ex) {
                return false;
            }
        }
        private set;
    }


    public String getMessage() {
        return getStatus().getSummary();
    }


    public String getSeverity() {
        return getStatus().getSeverity().name();
    }
    

    public PageReference doRun() {
        PageReference result = null;

        try {
            result = run();
        }
        catch(Exception ex) {
            ApexPages.addMessages(ex);
        }

        return result;
    }


    public String buttonLabel {
        get {
            return buttonLabel();
        }
    }


    public virtual String buttonLabel() {
        return 'Execute';
    }


    public virtual Boolean getShowButtonOnSuccess() {
        return false;
    }


    // PROTECTED

    protected List<SelectOption> metatdataOptions(String type) {
        List<SelectOption> result = new List<SelectOption>();

        HttpRequest request = new HttpRequest();
        request.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/v48.0/tooling/query?q=Select+Id,DeveloperName+FROM+' +  type);
        request.setMethod('GET');
        request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        request.setHeader('Content-Type', 'application/json');

        ToolingApiResponse response =
                            (ToolingApiResponse) JSON.deserialize(new Http().send(request).getBody(), ToolingApiResponse.class);

        for(SObject_x record : response.records) {
            result.add( new SelectOption(record.DeveloperName + ' ' + record.Id, record.DeveloperName) );
        }

        return result;
    }


    public static void create(MetadataService.Metadata metadata) {
        create( new List<MetadataService.Metadata>{ metadata } );
    }

    public static void create(List<MetadataService.Metadata> metadata) {
        handle( createInBatch(metadata) );
    }


    public static void overwrite(MetadataService.Metadata metadata) {
        overwrite( new List<MetadataService.Metadata>{ metadata } );
    }


    public static void overwrite(List<MetadataService.Metadata> metadata) {
        handle( mdApi().updateMetadata(metadata) );
    }


    public static MetadataService.Metadata readMetadata(String type, String fullName) {
        return mdApi().readMetadata(type, new List<String>{ fullName }).getRecords()[0];
    }


    // PRIVATE

    private static void handle(List<MetadataService.SaveResult> saveResults) {
        for(MetadataService.SaveResult result : saveResults) {
            if(result != null) {
                if(result.errors != null) {
                    List<String> messages = new List<String>();
                    messages.add(result.fullName);
                    for(MetadataService.Error error : result.errors) {
                        messages.add(error.message + ' (' + error.statusCode + ').' +
                                            ( error.fields!=null && error.fields.size() > 0 ?
                                                                ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
                    }

                    if(messages.size() > 0) {
                        throw new MetadataServiceException(String.join(messages, ' '));
                    }
                }

                if(!result.success) {
                    throw new MetadataServiceException('Metdata API called failed.');
                }
            }
        }
    }


    protected String setupLink(List<SObject> records) {
        SObjectType type = records.getSObjectType();
        Id id = null;

        if(!records.isEmpty() && records[0] != null) {
            type = records[0].getSObjectType();
            id = records[0].Id;
        }

        return setupLink(id, '' + type, type.getDescribe().getLabel());
    }


    protected String setupLink(SObject record) {
        return setupLink(new List<SObject>{ record });
    }


    protected String setupLink(SObjectType type) {
        return '<b><a href="/lightning/setup/ObjectManager/' + type + '/FieldsAndRelationships/view" target="_blank">' + type.getDescribe().getLabel() + '</a></b>';
    }


    protected String setupLink(String id, String type, String label) {
        return (id == null) ? '<b>' + label + '</b>'  : '<b><a href="/lightning/setup/' + type + '/page?address=%2F' + id +'" target="_blank">' + label + '</a></b>';
    }


    protected String setupLink(String fragment, String label) {
        return '<b><a href="/lightning/setup/' + fragment + '" target="_blank">' + label + '</a></b>';
    }


    protected String link(String label, String url) {
        return '<b><a href="' + url +'" target="_blank">' + label + '</a></b>';
    }


    protected PageReference currentPage() {
        PageReference result = Page.setup;
        result.setRedirect(true);
        return result;
    }

    // PRIVATE

    private static MetadataService.MetadataPort mdApi() {
        MetadataService.MetadataPort result = null;

        try {
            result = new MetadataService.MetadataPort();
            result.SessionHeader = new MetadataService.SessionHeader_element();
            result.SessionHeader.sessionId = UserInfo.getSessionId();
        }
        catch(Exception ex) {
            ApexPages.addMessages(ex);
        }

        return result;
    }


    // Note: Metadata service accepts only 10 records at a time
    private static List<MetadataService.SaveResult> createInBatch(List<MetadataService.Metadata> metadata) {
        List<MetadataService.SaveResult> result = new List<MetadataService.SaveResult>();

        List<MetadataService.Metadata> currentBatch = new List<MetadataService.Metadata>();
        Integer batchSize = 10;

        for(MetadataService.Metadata record : metadata) {
            currentBatch.add(record);

            if(currentBatch.size() == batchSize && !currentBatch.isEmpty()) {
                result.addAll(mdApi().createMetadata(currentBatch));
                currentBatch.clear();
            }
        }
        
        if(!currentBatch.isEmpty()) {
            result.addAll(mdApi().createMetadata(currentBatch));            
        }
        return result;
    }


    // INNER

    public abstract class ForBatch extends SetupStep {

        public abstract void execute();

        public virtual override ApexPages.Message getStatus() {
            if(countBatchWithStatus(new List<String>{'Failed', 'Aborted'}) > 0) {
                return new ApexPages.Message(ApexPages.Severity.ERROR, 'Batch job failed. Check the logs.');
            }
            else if(countBatchWithStatus(new List<String>{'Holding', 'Queued', 'Preparing', 'Processing'}) > 1) {
                return new ApexPages.Message(ApexPages.Severity.INFO, 'Batch job pending. Check the logs.');
            }
            else if(countBatchWithStatus(new List<String>{'Completed'}) == 1) {
                return new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Batch job completed.');
            }

            return null;
        }


        public override String buttonLabel() {
            return 'Run...';
        }


        public override PageReference run() {
            execute();
            return new PageReference('/apexpages/setup/listAsyncApexJobs.apexp');
        }


        private Integer countBatchWithStatus(List<String> statuses) {
            String className = String.valueOf(this).split(':')[0];
            return [SELECT COUNT() FROM AsyncApexJob WHERE Status IN :statuses AND ApexClass.Name LIKE :className];
        }
    }


    public class MetadataServiceException extends Exception {}


    public class ToolingApiResponse {
        public List<SObject_x> records;
    }


    public class SObject_x {
        public String Id;
        public String DeveloperName;
    }
}