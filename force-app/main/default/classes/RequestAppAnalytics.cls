public with sharing class RequestAppAnalytics implements Schedulable, Queueable, Database.AllowsCallouts {
    
    private List<Id> packageIds;
    private AppAnalyticsQueryRequest request;


    // Constructor

    public RequestAppAnalytics(List<Id> packageIds) {
        this.packageIds = packageIds;
    }

    
    public RequestAppAnalytics(AppAnalyticsQueryRequest request) {
        this.request = request;
    }


    // PUBLIC

    // Note: Will be called instantly from Setup or Scheduled
    public void execute() {
        submitAppAnalyticsRequest();
        
    }

    // Schedulable

    // Note: Entry point for Scheduler
    public void execute(SchedulableContext ctx) {
        execute();
    }


    // Queueable

    // Note: Entry Point for Polling for Results
    public void execute(QueueableContext ctx) {
        pollForResults();
    }



    // PRIVATE

    private void submitAppAnalyticsRequest() {
        
        request = new AppAnalyticsQueryRequest();
        request.DataType = 'PackageUsageLog';
        request.StartTime = Datetime.now().addDays(-1);
        request.EndTime = Datetime.now();
        request.PackageIds = String.join(packageIds, ',');
        insert request;
    }

    private void pollForResults() {
        //System.enqueueJob(new LogDownloader(aaqr.DownloadUrl, aaqr.DownloadExpirationTime, aaqr.DownloadSize));
    }



}
