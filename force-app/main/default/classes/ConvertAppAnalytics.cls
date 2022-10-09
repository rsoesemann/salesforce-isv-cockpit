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
        List<PackageUsageSummary__c> summaries = new List<PackageUsageSummary__c>();

        Map<Id, Id> realIds = lmaIdsByRealIds();

        for(Map<String, String> line : parse(csvResponse)) {
            PackageUsageSummary__c record = new PackageUsageSummary__c();
            record.txt_CustomEntity__c = line.get('custom_entity');
            record.txt_CustomEntityType__c = line.get('custom_entity_type');
            record.txt_ManagedPackageNamespace__c = line.get('managed_package_namespace');
            record.txt_Month__c = line.get('month');
            record.num_Creates__c = Integer.valueOf(line.get('num_creates'));
            record.num_Deletes__c = Integer.valueOf(line.get('num_deletes'));
            record.num_Reads__c = Integer.valueOf(line.get('num_reads'));
            record.num_Updates__c = Integer.valueOf(line.get('num_updates'));
            record.num_Views__c = Integer.valueOf(line.get('num_views'));
            record.ext_OrganizationId__c = line.get('organization_id');
            record.ext_PackageId__c = line.get('package_id');
            record.txt_UserIdToken__c = line.get('user_id_token');
            record.txt_UserType__c = line.get('user_type');
            
            // Note: Multi field index to avoid data duplication
            record.txt_CombinedKey__c = record.txt_UserIdToken__c + '-' + record.ext_OrganizationId__c + '-' + record.ext_PackageId__c + '-' + record.txt_CustomEntity__c + '-' +  record.txt_Month__c;

            summaries.add(record);
        }

        upsert as system summaries txt_CombinedKey__c;
    }


    // PRIVATE 

    @TestVisible
    private List<Map<String, String>> parse(String csv) {
        List<Map<String, String>> result = new List<Map<String, String>>();

        List<String> lines = csv.split('\n');
        Map<Integer, String> rowNames = parseHeader(lines.remove(0));

        for(String lineRaw : lines) {
            Map<String, String> lineParsed = new Map<String, String>();
            
            Integer index = 0;
            for(String value : lineRaw.split(',')) {
                lineParsed.put(rowNames.get(index++), value.trim());
            }

            result.add(lineParsed);
        }

        return result;
    }


    private Map<Integer, String> parseHeader(String csvHeaderLine) {
        Map<Integer, String> result = new Map<Integer, String>();

        Integer index = 0;
        for(String rowName : csvHeaderLine.split(',')) {
            result.put(index++, rowName.trim());
        }

        return result;
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
}