public class FallbackFormat extends ParseAppErrors.EmailFormat {

    public override String regex() {
        return '(005[A-Za-z0-9]{12})/(00D[A-Za-z0-9]{12})';
    }
    

    public override void populateFields(Matcher matcher, AppError__c error) {
        error.txt_UserId__c = matcher.group(1);
        error.txt_OrgId__c = matcher.group(2);
    }
}

