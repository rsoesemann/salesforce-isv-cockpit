public with sharing class ParseAppErrors {

    public static Boolean parseAlways = false;

    private static final List<Token> TOKENS = new List<Token>{
        new OrgUserToken().compile(),
        new ExceptionToken().compile(),
        new PageToken().compile(),
        new ClassToken().compile(),
        new ExceptionWithClassToken().compile(),
        new RecompileErrorToken().compile(),
        new TriggerToken().compile()        
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
        parse();
        linkToLma();
    }


    // PRIVATE

    private static List<AppError__c> changedBody(List<AppError__c> errors, Map<Id, AppError__c> old) {
        List<AppError__c> result = new List<AppError__c>();

        for(AppError__c error : errors) {
            Boolean bodyHasChanged = (error.txl_FullMailBody__c != old.get(error.Id).txl_FullMailBody__c);

            if(parseAlways || bodyHasChanged) {
                clearFields(error);
                result.add(error);
            }
        }

        return result;
    }


    private void parse() {
        for(AppError__c error : errors) {
            System.debug(LoggingLevel.ERROR, 'Error: ' + error.txl_FullMailBody__c.replaceAll('(\\r|\\n)+', ' '));

            for(Token token : TOKENS) {
                Matcher match = token.match( error.txl_FullMailBody__c );
                System.debug(LoggingLevel.ERROR, match);

                if(match.find()) {
                    token.populateFields(match, error);
                }
            }
        }
    }


    private static void clearFields(AppError__c error) {
        error.txt_UserId__c = null;
		error.txt_OrgId__c = null;
		error.txt_Namespace__c = null;
		error.txt_VisualforcePage__c = null;
		error.txt_ExceptionType__c = null;
		error.txt_ExceptionMessage__c = null;
        error.txt_ApexClass__c = null;
        
        error.lkp_License__c = null;
        error.lkp_Package__c = null;
        error.lkp_PackageVersion__c = null;
        error.lkp_Account__c = null;
    }



    private void linkToLma() {
        Map<String, List<AppError__c>> bySubscriber = groupBySubscriber();

        for(sfLma__License__c license : [SELECT sfLma__Package__c, sfLma__Package_Version__c, sfLma__Account__c,
                                                sfLma__Package__r.txt_Namespace__c, sfLma__Subscriber_Org_ID__c
                                         FROM sflma__License__c
                                         WHERE sfLma__Subscriber_Org_ID__c = :orgIds(bySubscriber)
                                         AND sfLma__Package__r.txt_Namespace__c = :namespaces(bySubscriber)]) {

            String key = subscriberKey(license);

            if(bySubscriber.containsKey(key)) {
                for(AppError__c error : bySubscriber.get(key)) {
                    error.lkp_License__c = license.Id;
                    error.lkp_Package__c = license.sfLma__Package__c;
                    error.lkp_PackageVersion__c = license.sfLma__Package_Version__c;
                    error.lkp_Account__c = license.sfLma__Account__c;
                }
            }
        }
    }


    private Map<String, List<AppError__c>> groupBySubscriber() {
        Map<String, List<AppError__c>> result = new Map<String, List<AppError__c>>();

        for(AppError__c error : errors) {
            String key = subscriberKey(error);

            if(!result.containsKey(key)) {
                result.put(key, new List<AppError__c>());
            }

            result.get(key).add(error);
        }

        return result;
    }


    private String subscriberKey(AppError__c error) {
        return namespace(error.txt_Namespace__c) + '_' + error.txt_OrgId__c;
    }


    private String subscriberKey(sflma__License__c license) {
        return namespace(license.sfLma__Package__r.txt_Namespace__c) + '_' + license.sfLma__Subscriber_Org_ID__c;
    }


    private String namespace(String namespace) {
        return (namespace == null) ? '' : namespace.toUpperCase();
    }


    private Set<String> namespaces(Map<String, List<AppError__c>> bySubscribers) {
        return fragmentOnly(bySubscribers.keySet(), 0);
    }


    private Set<String> orgIds(Map<String, List<AppError__c>> bySubscribers) {
        return fragmentOnly(bySubscribers.keySet(), 1);
    }


    private Set<String> fragmentOnly(Set<String> compoundKeys, Integer index) {
        Set<String> result = new Set<String>();

        for(String key : compoundKeys) {
            result.add( key.split('_')[index] );
        }

        return result;
    }


    // INNER

    public abstract class Token {

        private Pattern regex;

        public abstract String regex();
        public abstract void populateFields(Matcher match, AppError__c error);

        public Token compile() {
            regex = Pattern.compile(regex());
            return this;
        }

        public Matcher match(String text) {
            return regex.matcher(text);
        }

        protected String abbreviate(String value, Integer length) {
            return (value == null) ? null : value.abbreviate(length);
        }
    }
}