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
            error.txt_VisualforcePage__c = line.get('page_url');
            error.txt_ExceptionType__c = line.get('stack_trace');
            error.txt_ExceptionMessage__c = line.get('stack_trace');
            error.txt_ApexClass__c = line.get('class_name');
            error.lkp_Package__c = realIds.get( line.get('package_id') );
            error.lkp_PackageVersion__c = realIds.get( line.get('package_version_id') );

            errors.add(error);
        }

        insert errors;
    }


    // PRIVATE 

    @TestVisible
    private static List<Map<String, String>> parse(String csv) {
        List<Map<String, String>> result = new List<Map<String, String>>();

        List<String> lines = csv.split('\n');
        Map<Integer, String> rowNames = parseHeader(lines.remove(0));

        for(String lineRaw : lines) {
            Map<String, String> lineParsed = new Map<String, String>();
            
            Integer index = 0;
            for(String value : lineRaw.split(';')) {
                lineParsed.put(rowNames.get(index++), value.trim());
            }

            result.add(lineParsed);
        }

        return result;
    }


    @TestVisible
    private static Map<Integer, String> parseHeader(String csvHeaderLine) {
        Map<Integer, String> result = new Map<Integer, String>();

        Integer index = 0;
        for(String rowName : csvHeaderLine.split(';')) {
            result.put(index++, rowName.trim());
        }

        return result;
    }


    // Note: Taken from https://salesforce.stackexchange.com/questions/1013/parsing-an-iso-8601-timestamp-to-a-datetime
    private static DateTime dateFromIso8601(String iso8601Value) {
        DateTime result = (DateTime) JSON.deserialize('"' + iso8601Value + '"', DateTime.class);
        return DateTime.newInstance( result.getTime());
    }


    private Map<Id, Id> lmaIdsByRealIds() {
        Map<Id, Id> result = new Map<Id, Id>();

        for(sfLma__Package_Version__c p : [SELECT sfLma__Version_ID__c FROM sfLma__Package_Version__c]) {
            result.put(p.sfLma__Version_ID__c, p.Id);
        }

        for(sfLma__Package__c p : [SELECT sfLma__Package_ID__c FROM sfLma__Package__c]) {
            result.put(p.sfLma__Package_ID__c, p.Id);
        }

        return result;
    }
}
