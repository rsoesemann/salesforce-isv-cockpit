public with sharing class ClassToken extends ParseAppErrors.Token {

    public override String regex() {
        return '(class \'|Class\\.)([^.]+)\\.([^.\']+)';
    }


    public override void populateFields(Matcher match, AppError__c error) {
        error.txt_Namespace__c = match.group(1);
        error.txt_ApexClass__c = match.group(2);
    }
}