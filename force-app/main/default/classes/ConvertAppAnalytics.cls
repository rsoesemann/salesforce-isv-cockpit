public with sharing class ConvertAppAnalytics implements Queueable {

    private String csvResponse;


    // CTROR

    public ConvertAppAnalytics(String csvResponse) {
        this.csvResponse = csvResponse;
    }


    // PUBLIC

    public void execute() {
        if(Test.isRunningTest()) {
            execute(null);
        }
        else {
            System.enqueueJob( this );
        }
    }


    public void execute(QueueableContext ctx) {
        List<AppError__c> errors = new List<AppError__c>();

        Map<Id, Id> realIds = lmaIdsByRealIds();

        for(Map<String, String> line : parse(csvResponse)) {
            AppError__c error = new AppError__c();
            error.dtm_RecordedDate__c = dateFromIso8601( line.get('timestamp_derived') );
            error.txt_UserId__c = line.get('user_id_token');
            error.txt_OrgId__c = line.get('organization_id');
            error.txt_Namespace__c = line.get('managed_package_namespace');
            error.txt_VisualforcePage__c = line.get('url');
            error.lkp_Package__c = realIds.get( line.get('package_id') );
            error.lkp_PackageVersion__c = realIds.get( line.get('package_version_id') );

            StackTrace stackTrace = deserialize( line.get('stack_trace') );
            error.txt_ExceptionType__c = stackTrace.exceptionType;
            //error.txt_ExceptionMessage__c = line.get('stack_trace');
            
            StackFrame root = stackTrace.first();
            error.txt_ApexClass__c = firstNonEmpty(line.get('class_name') , root.namespace + '.' + root.clazz);
            error.txt_Method__c = firstNonEmpty(line.get('method_name') , root.method);

            errors.add(error);
        }

        insert as system errors;
    }


    // PRIVATE 

    @TestVisible
    private static List<Map<String, String>> parse(String csv) {
        List<Map<String, String>> result = new List<Map<String, String>>();

        for(Map<String, String> line : CsvParser.parseCsv(csv)) {
            if(isRelevant(line)) {
                result.add(line);
            }
        }

        return result;
    }


    // Note: Taken from https://salesforce.stackexchange.com/questions/1013/parsing-an-iso-8601-timestamp-to-a-datetime
    private static DateTime dateFromIso8601(String iso8601Value) {
        DateTime result = (DateTime) JSON.deserialize('"' + iso8601Value + '"', DateTime.class);
        return DateTime.newInstance( result.getTime());
    }


    private static Map<Id, Id> lmaIdsByRealIds() {
        Map<Id, Id> result = new Map<Id, Id>();

        for(sfLma__Package_Version__c p : [SELECT sfLma__Version_ID__c FROM sfLma__Package_Version__c]) {
            result.put(p.sfLma__Version_ID__c, p.Id);
        }

        for(sfLma__Package__c p : [SELECT sfLma__Package_ID__c FROM sfLma__Package__c]) {
            result.put(p.sfLma__Package_ID__c, p.Id);
        }

        return result;
    }


    private StackTrace deserialize(String stacktraceJson) {
        stacktraceJson = stacktraceJson.replace('"class":', '"clazz":');
        return (StackTrace) JSON.deserialize(stacktraceJson, StackTrace.class);
    }


    private static Boolean isRelevant(Map<String, String> line) {
        Set<String> relevantTypes = new Set<String>{'ApexUnexpectedException'};
        return relevantTypes.contains( line.get('log_record_type').trim() );
    }


    private String firstNonEmpty(String firstChoice, String secondChoice) {
        return (String.isBlank(firstChoice)) ? secondChoice : firstChoice;
    }


    // INNER

    private class StackTrace {
        private String exceptionType;
        private List<StackFrame> stackFrames;

        private stackFrame last() {
            return stackFrames.get(0);
        }

        private StackFrame first() {
            return stackFrames.get( stackFrames.size() - 1);
        }
    }

    private class StackFrame {
        private String scriptType;
        private String namespace;
        private String clazz;
        private String method;
        private Integer line;
        private Integer column;
    }
}