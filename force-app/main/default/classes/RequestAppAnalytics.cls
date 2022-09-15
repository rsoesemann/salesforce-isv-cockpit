public with sharing class RequestAppAnalytics implements Schedulable, Queueable, Database.AllowsCallouts {
    
    private AppAnalyticsQueryRequest request;

    // Constructor

    public RequestAppAnalytics(List<Id> packageId) {

    }

    // PUBLIC

    public void execute() {
        submitAppAnalyticsRequest();
        pollForResults();
    }

    // Schedulable

    public void execute(SchedulableContext ctx) {
        execute();
    }


    // Queueable

    public void execute(QueueableContext ctx) {
        
    }



    // PRIVATE

    private void submitAppAnalyticsRequest() {
        Date s = Date.today().addMonths(-1).toStartOfMonth();
        DateTime startTime = DateTime.newInstanceGMT(s.year(), s.month(), s.day(), 0,0,0);

        Date e = Date.today().toStartOfMonth().addDays(-1);
        DateTime endTime = DateTime.newInstanceGMT(e.year(), e.month(), e.day(), 23,59,59);
        
        request = new AppAnalyticsQueryRequest();
        request.DataType = 'PackageUsageLog';
        request.StartTime = startTime;
        request.EndTime = endTime;
        insert request;
    }

    private void pollForResults() {
        //System.enqueueJob(new LogDownloader(aaqr.DownloadUrl, aaqr.DownloadExpirationTime, aaqr.DownloadSize));
    }
}
