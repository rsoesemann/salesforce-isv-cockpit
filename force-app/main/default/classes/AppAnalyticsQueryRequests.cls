public with sharing class AppAnalyticsQueryRequests extends fflib_SObjectDomain {

    // CONSTRUCTOR

    public AppAnalyticsQueryRequests(List<AppAnalyticsQueryRequest> sObjectList) {
        super(sObjectList);
    }


    // PUBLIC

    public override void onAfterUpdate(Map<Id, SObject> old) {
        new FetchAppAnalyticsData(records).execute();
    }


    // INNER

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new AppAnalyticsQueryRequests(sObjectList);
        }
    }
}