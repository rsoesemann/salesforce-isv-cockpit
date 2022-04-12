public with sharing class OrgUserToken extends ParseAppErrors.Token {

    public override String regex() {
        return '(005[A-Za-z0-9]{12})/(00D[A-Za-z0-9]{12})';
    }


    public override void populateFields(Matcher match, AppError__c error) {
        error.txt_UserId__c = match.group(1);
        error.txt_OrgId__c = match.group(2);
    }
}