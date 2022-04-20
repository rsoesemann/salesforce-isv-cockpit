public with sharing class ExceptionWithClassToken extends ParseAppErrors.Token {

    public override String regex() {
        return '[\\n\\r]+([^.]+)\\.([^.\' ]+): (.+Exception): (.+)';
    }


    public override void populateFields(Matcher match, AppError__c error) {
        error.txt_Namespace__c = match.group(1);
        error.txt_ApexClass__c = match.group(2);
        error.txt_ExceptionType__c = match.group(3);
        error.txt_ExceptionMessage__c = abbreviate(match.group(4), 255);
    }}