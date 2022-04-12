public with sharing class ExceptionToken extends ParseAppErrors.Token {

    public override String regex() {
        return ': (.+Exception): (.*)';
    }


    public override void populateFields(Matcher match, AppError__c error) {
        error.txt_ExceptionType__c = match.group(1);
        error.txt_ExceptionMessage__c = abbreviate(match.group(2), 255);
    }
}