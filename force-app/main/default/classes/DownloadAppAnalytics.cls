public with sharing class DownloadAppAnalytics  implements Triggers.Handler,
                                                            Triggers.AfterUpdate,
                                                            Queueable, Database.AllowsCallouts {

    private List<AppAnalyticsQueryRequest> requests;


    // CTROR

    public DownloadAppAnalytics() {
        // Note: Default ctor needed for Trigger framework
    }


    public DownloadAppAnalytics(List<AppAnalyticsQueryRequest> requests) {
        this.requests = requests;
    }


    public DownloadAppAnalytics(AppAnalyticsQueryRequest request) {
        this(new List<AppAnalyticsQueryRequest>{ request });
    }


    // PUBLIC

    public Boolean criteria(Triggers.Context ctx) {
        return Triggers.WHEN_ALWAYS;
    }


    public void afterUpdate(Triggers.Context ctx) {
        new DownloadAppAnalytics(ctx.props.newList).execute();
    }


    @SuppressWarnings('PMD.OperationWithLimitsInLoop')  // Note: We explicitly check for Limits in loop
    public void execute() {
        for(AppAnalyticsQueryRequest request : requests) {
            if(isComplete(request) && canEnqueueMore()) {
                System.enqueueJob( new DownloadAppAnalytics(request) );
            }
        }
    }


    public void execute(QueueableContext ctx) {
        for(AppAnalyticsQueryRequest request : requests) {
            if(isDownloadable(request)) {
                HttpRequest httpRequest = new HttpRequest();
                httpRequest.setMethod('GET');
                httpRequest.setEndpoint(request.DownloadUrl);
                
                HttpResponse response = new Http().send(httpRequest);
                if(response.getStatusCode() == 200) {
                    new ConvertAppAnalytics(response.getBody()).execute(); 
                }
                else {
                    System.debug(LoggingLevel.ERROR, 'Download failed with Code: ' + response.getStatusCode() + ' + Message: ' + response.getStatusCode());
                }
            }
            else {
                System.debug(LoggingLevel.ERROR, 'Request result not downloadable.');
            }
        }
    }


    // PRIVATE

    private Boolean isComplete(AppAnalyticsQueryRequest request) {
        return (request.RequestState == 'Complete' && request.DataType == 'PackageUsageSummary');
    }


    private Boolean isDownloadable(AppAnalyticsQueryRequest request) {
        return (notExpired(request) && request.DownloadSize < remainingHeap());
    }


    private Boolean notExpired(AppAnalyticsQueryRequest request) {
        return (request.DownloadExpirationTime > DateTime.now());
    }


    private Integer remainingHeap() {
        return (Limits.getLimitHeapSize() - Limits.getHeapSize());
    }


    private Boolean canEnqueueMore() {
        return (Limits.getLimitQueueableJobs() > Limits.getQueueableJobs());
    }
}