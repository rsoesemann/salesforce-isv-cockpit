// Note: Otherwise the Admin running this needs to own all Account and Licences
public without sharing class ParseAppErrors implements Triggers.Handler,
                                                        Triggers.BeforeInsert,
                                                        Triggers.BeforeUpdate {

    public static Boolean parseAlways = false;
    
    private static final List<Tokenizer> TOKENIZERS = Tokenizer.initialize();

    private List<AppError__c> errors;


    // CONSTRUCTOR

    public ParseAppErrors(List<AppError__c> inserted) {
        errors = inserted;
    }

    
    public ParseAppErrors(AppError__c error) {
        this(new List<AppError__c>{ error });
    }


    public ParseAppErrors(List<AppError__c> errors, Map<Id, AppError__c> old) {
        this( changedBody(errors, old) );
    }


    // PUBLIC

    public Boolean criteria(Triggers.Context ctx) {
        return Triggers.WHEN_ALWAYS;
    }


    public void beforeInsert(Triggers.Context ctx) {
        new ParseAppErrors(ctx.props.newList).execute();
    }


    public void beforeUpdate(Triggers.Context ctx) {
        new ParseAppErrors( changedBody((List<AppError__c>) ctx.props.newList, (Map<Id, AppError__c>) ctx.props.oldMap) ).execute();
    }
      

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
            if(String.isNotBlank(error.txl_FullMailBody__c)) {
                for(Tokenizer tokenizer : TOKENIZERS) {
                    tokenizer.execute(error);
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
                                                sfLma__Package__r.txt_Namespace__c, sfLma__Subscriber_Org_ID__c,
                                                (SELECT NewValue, CreatedDate FROM Histories 
                                                 WHERE Field = 'sfLma__Package_Version__c' AND DataType = 'EntityId'
                                                 ORDER BY CreatedDate DESC) 
                                         FROM sflma__License__c
                                         WHERE sfLma__Subscriber_Org_ID__c = :orgIds(bySubscriber)
                                         AND sfLma__Package__r.txt_Namespace__c = :namespaces(bySubscriber)
                                         WITH SYSTEM_MODE]) {
            String key = subscriberKey(license);

            if(bySubscriber.containsKey(key)) {
                for(AppError__c error : bySubscriber.get(key)) {
                    error.lkp_License__c = license.Id;
                    error.lkp_Package__c = license.sfLma__Package__c;
                    error.lkp_PackageVersion__c = findVersion(error, license);
                    error.lkp_Account__c = license.sfLma__Account__c;
                }
            }
        }
    }


    // Note: Assignes not current but actual version during error creation
    //       Important when importing historical app errors
    private Id findVersion(AppError__c error, sfLma__License__c license) {
        Id result = license.sfLma__Package_Version__c;

        if(notRecordedLive(error)) {
            for(sfLma__License__History history : license.Histories) {
                // Note: Break as this is the right one due to order by
                if(history.CreatedDate < error.dtm_RecordedDate__c) {
                    result = (Id) history.NewValue;
                    break;
                }
                // Note: History limits hit. Just take the oldest version
                //       https://help.salesforce.com/s/articleView?id=release-notes.rn_pds_field_history_tracking_deletion.htm&type=5&release=216
                else {
                    result = (Id) history.NewValue;
                }
            }
        }

        return result;
    }


    private Boolean notRecordedLive(AppError__c error) {
        // Note: Only equals when error received as email 
        return (error.CreatedDate > error.dtm_RecordedDate__c);
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
        return (namespace == null) ? '' : namespace.toUpperCase().trim();
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
}