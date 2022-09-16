trigger AppAnalyticsQueryRequests on AppAnalyticsQueryRequest (after update) {
    fflib_SObjectDomain.triggerHandler(AppAnalyticsQueryRequests.class);
}