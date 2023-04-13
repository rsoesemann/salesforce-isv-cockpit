public with sharing class ArchiveRecords implements Database.Batchable<SObject>, Schedulable {
    
    private SObjectType source;
    private SObjectType target;
    private CorrespondingFields mapping;
    private String filter;

    @TestVisible private List<SObject> archived;
    @TestVisible private List<SObject> deleted;


    // CONSTRUCTOR

    public ArchiveRecords(SObjectType source, SObjectType target, String filter) {
        this.source = source;
        this.target = target;
        mapping = new CorrespondingFields(source, target);
        this.filter = (String.isEmpty(filter)) ? null : filter;
    }


    // PUBLIC

    public void execute() {
        if(!Test.isRunningTest()) {
            Database.executeBatch(this);
        }
        else {
            Database.BatchableContext ctx = null;
            deleted = allFrom(start(ctx));
            archived = archiveRecordsOf(deleted);
        }
    }


    // SCHEDULABLE

    public void execute(SchedulableContext sc) {
        execute();
    }


    // BATCH

    public Database.QueryLocator start(Database.BatchableContext ctx) {
        return SOQL.of(source)
                    .with(new List<SObjectField>(mapping.sourceFields(source) ))
                    .whereAre(filter)
                    .systemMode()
                    .asQueryLocator();
    }


    public void execute(Database.BatchableContext ctx, List<SObject> originalRecords) {   
        Database.insertImmediate( archiveRecordsOf(originalRecords), AccessLevel.SYSTEM_MODE );
        Database.deleteAsync(originalRecords, AccessLevel.SYSTEM_MODE);
    }


    public void finish(Database.BatchableContext ctx) { }


    // PRIVATE

    private List<SObject> archiveRecordsOf(List<SObject> originalRecords) {
        List<SObject> result = new List<SObject>();

        for(SObject original : originalRecords) {
            SObject archived = target.newSObject();

            for(SObjectField targetField : mapping.targetFields(source)) {
                SObjectField sourceField = mapping.sourceField(targetField);
                archived.put(targetField, original.get(sourceField));
            }

            archived.put('dtm_ArchivedDate__c', System.now());

            result.add(archived);
        } 

        return result;
    }


    private List<SObject> allFrom(Database.QueryLocator locator) {
        List<SObject> result = new List<SObject>();

        Database.QueryLocatorIterator iterator = locator.iterator();
        while(iterator.hasNext()) {
            result.add(iterator.next());
        }

        return result;
    }
}