public with sharing class DownloadAppAnalytics implements Queueable, Database.AllowsCallouts {

    private List<AppAnalyticsQueryRequest> requests;


    // CTROR

    public DownloadAppAnalytics(List<AppAnalyticsQueryRequest> requests) {
        this.requests = requests;
    }


    public DownloadAppAnalytics(AppAnalyticsQueryRequest request) {
        this(new List<AppAnalyticsQueryRequest>{ request });
    }


    // PUBLIC

    public void execute() {
        for(AppAnalyticsQueryRequest request : requests) {
            if(isComplete(request)) {
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
        return (request.RequestState == 'Complete' && request.DataType == 'PackageUsageLog');
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
}
