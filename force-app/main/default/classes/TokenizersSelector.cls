public with sharing class TokenizersSelector extends fflib_SObjectSelector {

    // PUBLIC

    public Schema.SObjectType getSObjectType() {
        return Tokenizer__mdt.SObjectType;
    }


    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Tokenizer__mdt.Id,
            Tokenizer__mdt.DeveloperName,
            Tokenizer__mdt.Label,
            Tokenizer__mdt.chk_IsActive__c,
            Tokenizer__mdt.num_Position__c,
            Tokenizer__mdt.txl_RegExp__c,
            Tokenizer__mdt.txt_Group1Field__c,
            Tokenizer__mdt.txt_Group2Field__c,
            Tokenizer__mdt.txt_Group3Field__c,
            Tokenizer__mdt.txt_Group4Field__c,
            Tokenizer__mdt.txt_Group5Field__c
        };
    }


    public List<Tokenizer__mdt> allActiveInOrder() {
        return (List<Tokenizer__mdt>) Database.query( newQueryFactory()
                                                                .setCondition('chk_IsActive__c = TRUE')
                                                                .setOrdering(Tokenizer__mdt.num_Position__c, fflib_QueryFactory.SortOrder.ASCENDING)
                                                                .toSOQL() );
    }
}