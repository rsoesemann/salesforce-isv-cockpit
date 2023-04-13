trigger AppAnalyticsQueryRequests on AppAnalyticsQueryRequest (after update) {
    Triggers.prepare()
            .afterUpdate()
                .bind( new DownloadAppAnalytics() )
            .execute();
}