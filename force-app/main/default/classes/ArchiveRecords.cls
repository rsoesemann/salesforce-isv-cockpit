public with sharing class ArchiveRecords implements Database.Batchable<SObject>, Schedulable {
    
    private SObjectType source;
    private SObjectType target;
    private String condition;


    // CONSTRUCTOR

    public ArchiveRecords(SObjectType source, SObjectType target, String filter) {
        this.source = source;
        this.target = target;
        condition = filter;
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
        return Database.getQueryLocator(sanitized('SELECT FIELDS(ALL) FROM ' + source + ' WHERE ' + condition));
    }


    public void execute(Database.BatchableContext ctx, List<SObject> originalRecords) {
        Database.insertImmediate( archiveRecordsOf(originalRecords) );
        Database.deleteAsync(originalRecords);
    }


    public void finish(Database.BatchableContext ctx) { }


    // PRIVATE

    private List<SObject> archiveRecordsOf(List<SObject> originalRecords) {
        List<SObject> result = new List<SObject>();

        CorrespondingFields mapping = new CorrespondingFields(source, target);

        for(SObject original : originalRecords) {
            SObject archived = target.newSObject();

            for(SObjectField targetField : mapping.targetFields(source)) {
                SObjectField sourceField = mapping.sourceField(targetField);
                archived.put(targetField, original.get(sourceField));

                result.add(archived);
            }
        } 
        
        return result;
    }


    private String sanitized(String soqlWithInjectionFlaw) {
        // Note: https://salesforce.stackexchange.com/questions/206284/soql-injection-vulnerability
        return String.escapeSingleQuotes(soqlWithInjectionFlaw);
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