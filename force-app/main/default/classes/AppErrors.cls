public with sharing class AppErrors extends fflib_SObjectDomain {

    // CONSTRUCTOR

    public AppErrors(List<AppError__c> sObjectList) {
        super(sObjectList);
    }


    // PUBLIC

    public override void onBeforeInsert() {
        new ParseAppErrors(records).execute();
    }


    public override void onBeforeUpdate(Map<Id, SObject> old) {
        new ParseAppErrors(records, cast(old)).execute();
    }


    // PRIVATE

    private Map<Id, AppError__c> cast(Map<Id, SObject> uncasted) {
        return (Map<Id, AppError__c>) uncasted;
    }


    // INNER

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new AppErrors(sObjectList);
        }
    }
}