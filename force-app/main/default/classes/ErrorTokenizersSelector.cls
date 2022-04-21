public with sharing class ErrorTokenizersSelector extends fflib_SObjectSelector {

    // PUBLIC

    public Schema.SObjectType getSObjectType() {
        return ErrorTokenizer__mdt.SObjectType;
    }


    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            ErrorTokenizer__mdt.Id,
            ErrorTokenizer__mdt.DeveloperName,
            ErrorTokenizer__mdt.Label,
            ErrorTokenizer__mdt.chk_IsActive__c,
            ErrorTokenizer__mdt.num_Position__c,
            ErrorTokenizer__mdt.txl_RegExp__c,
            ErrorTokenizer__mdt.txt_Group1Field__c,
            ErrorTokenizer__mdt.txt_Group2Field__c,
            ErrorTokenizer__mdt.txt_Group3Field__c,
            ErrorTokenizer__mdt.txt_Group4Field__c,
            ErrorTokenizer__mdt.txt_Group5Field__c
        };
    }


    public List<ErrorTokenizer__mdt> allActiveInOrder() {
        return (List<ErrorTokenizer__mdt>) Database.query( newQueryFactory()
                                                                .setCondition('chk_IsActive__c = TRUE')
                                                                .setOrdering(ErrorTokenizer__mdt.num_Position__c, fflib_QueryFactory.SortOrder.ASCENDING)
                                                                .toSOQL() );
    }
}