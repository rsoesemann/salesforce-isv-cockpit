public with sharing class ArchiveRecords implements Database.Batchable<SObject>, Schedulable {
    
    private SObjectType source;
    private SObjectType target;
    private CorrespondingFields mapping;
    private String filter;


    // CONSTRUCTOR

    public ArchiveRecords(SObjectType source, SObjectType target, String filter) {
        this.source = source;
        this.target = target;
        mapping = new CorrespondingFields(source, target);
        this.filter = (String.isEmpty(filter)) ? null : filter;
    }


    // PUBLIC

    public void execute() {
        if(Test.isRunningTest()) {
            executeSynchronously();
        }
        else {
            Database.executeBatch(this);
        }
    }


    public void executeSynchronously() {
        Database.BatchableContext ctx = null;
        
        Database.QueryLocator locator = start(ctx);
        execute(ctx, allFrom(locator));
        finish(ctx);
    }


    // SCHEDULABLE

    public void execute(SchedulableContext sc) {
        execute();
    }


    // BATCH

    public Database.QueryLocator start(Database.BatchableContext ctx) {
        return Database.getQueryLocator(new fflib_QueryFactory(source)
                                                    .selectFields( mapping.sourceFields(source) )
                                                    .setCondition(filter)
                                                    .toSOQL());
    }


    public void execute(Database.BatchableContext ctx, List<SObject> originalRecords) {         
        List<Database.SaveResult> srList = Database.insertImmediate( archiveRecordsOf(originalRecords) );
        System.debug(LoggingLevel.ERROR, srList);
        //Database.deleteAsync(originalRecords);
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