// Note: It's the libs decision to call it like that
@SuppressWarnings('PMD.PropertyNamingConventions')
public with sharing class TokenizersSelector {

    public static SOQL Query {
        get {
            return SOQL.of(Tokenizer__mdt.SObjectType).with(new List<SObjectField>{
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
            })
            .systemMode()
            .withoutSharing();
        }
    }


    public List<Tokenizer__mdt> allActiveInOrder() {
        return Query
                .whereAre(SOQL.Filter.with(Tokenizer__mdt.chk_IsActive__c).equal(true))
                .orderBy(Tokenizer__mdt.num_Position__c)
                .asList();
    }
}