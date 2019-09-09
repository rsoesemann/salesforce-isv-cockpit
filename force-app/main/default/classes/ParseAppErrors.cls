public with sharing class ParseAppErrors {

    private static final List<EmailFormat> FORMATS = new List<EmailFormat>{
            new PageErrorFormat(),
            new TriggerErrorFormat()
    };

    private List<AppError__c> errors;


    // CONSTRUCTOR

    public ParseAppErrors(List<AppError__c> inserted) {
        errors = inserted;
    }


    public ParseAppErrors(List<AppError__c> errors, Map<Id, AppError__c> old) {
        this( changedBody(errors, old) );
    }


    // PUBLIC

    public void execute() {
        for(AppError__c error : errors) {
            for(EmailFormat format : FORMATS) {
                Matcher matcher = format.matcher( error.txl_FullMailBody__c );

                if(matcher.find()) {
                    error.txt_MatchedWith__c = String.valueOf(format).split(':')[0];

                    format.populateFields(matcher, error);
                    linkToLma(error);

                    break;
                }
            }
        }
    }


    // PRIVATE

    private static List<AppError__c> changedBody(List<AppError__c> errors, Map<Id, AppError__c> old) {
        List<AppError__c> result = new List<AppError__c>();

        for(AppError__c error : errors) {
            if(error.txl_FullMailBody__c != old.get(error.Id).txl_FullMailBody__c) {
                result.add(error);
            }
        }

        return result;
    }


    private void linkToLma(AppError__c error) {
        for(sfLma__License__c license : [SELECT sfLma__Package__c, sfLma__Package_Version__c, sfLma__Account__c
                                         FROM sflma__License__c
                                         WHERE sfLma__Subscriber_Org_ID__c = :error.txt_OrgId__c
                                         AND sfLma__Package__r.txt_Namespace__c = :error.txt_Namespace__c]) {
            error.lkp_License__c = license.Id;
            error.lkp_Package__c = license.sfLma__Package__c;
            error.lkp_PackageVersion__c = license.sfLma__Package_Version__c;
            error.lkp_Account__c = license.sfLma__Account__c;
        }
    }


    // INNER

    public abstract class EmailFormat {

        public abstract String regex();
        public abstract void populateFields(Matcher matcher, AppError__c error);

        public Matcher matcher(String text) {
            Pattern pattern = Pattern.compile(regex());
            return pattern.matcher(text);
        }
    }
}