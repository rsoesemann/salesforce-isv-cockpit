public with sharing class RequestAppAnalytics implements Schedulable {

    public static final String JOB_NAME = 'IsvCockpit_RequestAppAnalytics';
    public static final Integer USERS_PER_CHUNK = 100;

    @TestVisible
    private List<AppAnalyticsQueryRequest> requests = new List<AppAnalyticsQueryRequest>();

    private CronTrigger job;

    // CTOR

    public RequestAppAnalytics(CronTrigger job) {
        this.job = job;
    }


    // PUBLIC

    public void activate() {
        if(Test.isRunningTest()) {
            execute(null);
        }
        else {
            System.schedule(JOB_NAME, job.cronExpression, this);
        }
    }


    public void deactivate() {
        System.purgeOldAsyncJobs(Date.today().addDays(1));

        if(job != null) {
            System.abortJob(job.Id);
        }
    }


    public void execute(System.SchedulableContext ctx) {
        createWellSizedRequestForAllSubscribers();
        insertRequestsWhenAnalyticsEnabled();
    }


    public static CronTrigger queryJob() {
        CronTrigger result = null;

        for(CronTrigger job : [SELECT CronJobDetail.Name, StartTime, CronExpression, NextFireTime, PreviousFireTime 
                               FROM CronTrigger WHERE CronJobDetail.Name LIKE :RequestAppAnalytics.JOB_NAME]) {
            result = job;
        }

        return result;
    }


    // PRIVATE

    private void createWellSizedRequestForAllSubscribers() {
        SubscriberIterator subscribers = new SubscriberIterator();

        while(subscribers.hasNext()) {
            List<Id> orgIds = new List<Id>();
            List<Id> packageIds = new List<Id>();
            Integer userCount = 0;

            while(userCount <= USERS_PER_CHUNK) {
                AggregateResult subscriber = subscribers.next();

                orgIds.add((Id) subscriber.get('sfLma__Subscriber_Org_ID__c'));
                packageIds.add((Id) subscriber.get('sfLma__Package__r.sfLma__Package_ID__c'));
                userCount += (Integer) subscriber.get('users');
            }

            requests.add( requestFor(orgIds, packageIds) );
        }
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
        result.DataType = 'PackageUsageLog';
        result.EndTime = job.NextFireTime;
        result.StartTime = job.NextFireTime.addMinutes(- minutesBetweenJob());
        result.PackageIds = String.join(packages, ',');
        result.OrganizationIds = String.join(subscribers, ',');
        return result;
    }


    private Integer minutesBetweenJob() {
        Datetime nextRun = job.NextFireTime;
        Datetime lastRun = (job.PreviousFireTime == null) ? nextRun.addDays(-1) : job.PreviousFireTime;

        Integer result = Integer.valueOf((nextRun.getTime() - lastRun.getTime()) / (1000*60));
        return result;
    }


    // INNER

    private with sharing class SubscriberIterator implements Iterator<AggregateResult>{ 

        private Integer currentIndex;
        private List<AggregateResult> aggregates;

        public SubscriberIterator() {
            currentIndex = 0;
            aggregates = [SELECT sfLma__Subscriber_Org_ID__c, sfLma__Package__r.sfLma__Package_ID__c, SUM(sfLma__Used_Licenses__c) users
                            FROM sfLma__License__c
                            WHERE sfLma__Status__c IN ('Active', 'true') 
                            AND sfLma__Used_Licenses__c > 0
                            GROUP BY sfLma__Package__r.sfLma__Package_ID__c, sfLma__Subscriber_Org_ID__c
                            ORDER BY SUM(sfLma__Used_Licenses__c)];
        }

        public boolean hasNext() { 
            return currentIndex < aggregates.size() - 1;
        }    

        public AggregateResult next() {
            if(hasNext()) {
                currentIndex++;
                return aggregates[currentIndex];
            } 
            else {
                throw new NoSuchElementException();
            }
        } 
    }
}