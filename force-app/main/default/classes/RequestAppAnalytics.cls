public with sharing class RequestAppAnalytics implements Schedulable {

    public static final Integer USERS_PER_CHUNK = 100;

    @TestVisible
    private static List<AppAnalyticsQueryRequest> requests = new List<AppAnalyticsQueryRequest>();


    // PUBLIC

    public void execute(System.SchedulableContext ctx) {
        createWellSizedRequestForAllSubscribers();
        insertRequestsWhenAnalyticsEnabled();
    }


    // PRIVATE

    private void createWellSizedRequestForAllSubscribers() {
        SubscriberIterator subscribers = new SubscriberIterator();

        do {
            List<Id> orgIds = new List<Id>();
            List<Id> packageIds = new List<Id>();
            Integer userCount = 0;

            while(subscribers.hasNext() && userCount <= USERS_PER_CHUNK) {
                AggregateResult subscriber = subscribers.next();

                orgIds.add((Id) subscriber.get('orgId'));
                packageIds.add((Id) subscriber.get('packageId'));
                userCount += Integer.valueOf( subscriber.get('users') );
            }

            requests.add( requestFor(orgIds, packageIds) );
        } while(subscribers.hasNext());
    }


    private void insertRequestsWhenAnalyticsEnabled() {
        try {
            insert requests;
        }
        catch(Exception ignored) {
            System.debug(LoggingLevel.ERROR, '(In Scratch orgs this is ok) ' + ignored);
        }
    }


    private AppAnalyticsQueryRequest requestFor(List<Id> subscribers, List<Id> packages) {
        AppAnalyticsQueryRequest result = new AppAnalyticsQueryRequest();
        result.DataType = 'PackageUsageSummary';
        result.PackageIds = '033xx00SIMsmall'; // TODO String.join(packages, ',');
        result.OrganizationIds = ''; //String.join(subscribers, ',');
        
        Date s = Date.today().addMonths(-1).toStartOfMonth();
        result.StartTime = DateTime.newInstanceGMT(s.year(), s.month(), s.day(), 0,0,0);
        
        Date e = Date.today().toStartOfMonth().addDays(-1);
        result.EndTime = DateTime.newInstanceGMT(e.year(), e.month(), e.day(), 23,59,59);

        return result;
    }


    // INNER

    private with sharing class SubscriberIterator implements Iterator<AggregateResult>{ 

        private Integer index = 0;
        private List<AggregateResult> results;

        public SubscriberIterator() {
            results = [SELECT sfLma__Subscriber_Org_ID__c orgId, sfLma__Package__r.sfLma__Package_ID__c packageId, SUM(sfLma__Used_Licenses__c) users
                            FROM sfLma__License__c
                            WHERE sfLma__Status__c IN ('Active') 
                            AND sfLma__Used_Licenses__c > 0
                            GROUP BY sfLma__Package__r.sfLma__Package_ID__c, sfLma__Subscriber_Org_ID__c
                            ORDER BY SUM(sfLma__Used_Licenses__c)];
        }

        public boolean hasNext() { 
            return (index < results.size());
        }    

        public AggregateResult next() {
            if(hasNext()) {
                return results[index++];
            } 
            else {
                throw new NoSuchElementException();
            }
        } 
    }
}