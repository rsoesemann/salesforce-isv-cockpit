public with sharing class ParseAppErrors {

    private static final Pattern ORIGIN_REGEXP = Pattern.compile('(005[A-Za-z0-9]{12})/(00D[A-Za-z0-9]{12})');
    private static final Pattern TRIGGER_REGEXP = Pattern.compile('[\\s]+((.+?)\\.(.+?)): (.+?): (.+)');
    private static final Pattern PAGE_REGEXP
                    = Pattern.compile('[\\s]+.+/(.+)__(.+)[\\s]+caused by: ((.+?): (.+))[\\s]+Class\\.((.+)\\.(.+))');

    private List<AppError__c> errors;


    // CONSTRUCTOR

    public ParseAppErrors(List<AppError__c> inserted) {
        errors = inserted;
    }


    public ParseAppErrors(List<AppError__c> errors, Map<Id, AppError__c> old) {
        this( (List<AppError__c>) new SObjects(errors).changes(old, AppError__c.txl_FullMailBody__c).records() );
    }


    // PUBLIC

    public void execute() {
        for(AppError__c error : errors) {
            String body = error.txl_FullMailBody__c;

            Matcher originMatch = ORIGIN_REGEXP.matcher(body);

            if(originMatch.find()) {
                error.txt_UserId__c = originMatch.group(1);
                error.txt_OrgId__c = originMatch.group(2);

                Matcher pageMatch = PAGE_REGEXP.matcher(body);
                Matcher triggerMatch = TRIGGER_REGEXP.matcher(body);

                if(pageMatch.find()) {
                    error.txt_Namespace__c = pageMatch.group(1).toUpperCase();
                    error.txt_VisualforcePage__c = pageMatch.group(2);
                    error.txt_ExceptionType__c = pageMatch.group(4);
                    error.txt_ExceptionMessage__c = pageMatch.group(5);
                    error.txt_Location__c = pageMatch.group(6);
                    error.txt_ApexClass__c = pageMatch.group(7);
                }
                else if(triggerMatch.find()) {
                    error.txt_Location__c = triggerMatch.group(1);
                    error.txt_Namespace__c = triggerMatch.group(2);
                    error.txt_ApexClass__c = triggerMatch.group(3);
                    error.txt_ExceptionType__c = triggerMatch.group(4);
                    error.txt_ExceptionMessage__c = triggerMatch.group(5);
                }

                for(sfLma__License__c license : [
                                    SELECT sfLma__Package__c, sfLma__Package_Version__c, sfLma__Account__c
                                    FROM sflma__License__c
                                    WHERE sfLma__Subscriber_Org_ID__c = :error.txt_OrgId__c
                                    AND sfLma__Package__r.txt_Namespace__c = :error.txt_Namespace__c
                                    LIMIT 1]) {
                    error.lkp_License__c = license.Id;
                    error.lkp_Package__c = license.sfLma__Package__c;
                    error.lkp_PackageVersion__c = license.sfLma__Package_Version__c;
                    error.lkp_Account__c = license.sfLma__Account__c;
                }
            }

            if(!isPopulated(error)) {
                System.debug(LoggingLevel.ERROR, 'Failed to match: ' + stripBreaks(body));
                System.debug(LoggingLevel.ERROR, stripBreaks(String.valueOf(error)));
            }
        }
    }


    // PRIVATE

    @TestVisible
    private static Boolean isPopulated(AppError__c error) {
        return (error.txt_UserId__c != null
             && error.txt_OrgId__c != null
             && error.txt_Namespace__c != null
             && (error.txt_ApexClass__c != null || error.txt_VisualforcePage__c != null)
             && error.txt_Location__c != null
             && error.txt_ExceptionMessage__c != null
             && error.txt_ExceptionType__c != null
             && error.lkp_License__c != null
             && error.lkp_Package__c != null
             && error.lkp_PackageVersion__c != null
             && error.lkp_Account__c != null);
    }


    private String stripBreaks(String input){
        return input.replaceAll('(\\r|\\n)+', '|');
    }
}