@IsTest
private class DownloadAppAnalytics_Test {

    private static final Blob CSV = [SELECT Body FROM StaticResource WHERE Name = 'error_logs_csv'].Body;


    @IsTest
    private static void execute() {
        
        // Setup
        new HttpMock()
                .get('/download', CSV, 200)
                .mock();

        AppAnalyticsQueryRequest request = (AppAnalyticsQueryRequest) HttpMock.object(AppAnalyticsQueryRequest.SObjectType, new Map<String, Object>{
                                                'RequestState' => 'Complete',
                                                'DataType' => 'PackageUsageLog',
                                                'DownloadExpirationTime' => System.now().addDays(1),
                                                'DownloadSize' => CSV.size(),
                                                'DownloadUrl' => 'https://no-real-url.com/download'
                                            });
        // Exercise
        Test.startTest();                                   
        new DownloadAppAnalytics(request).execute();
        Test.stopTest();


        // Verify
        System.assert( ![SELECT Id FROM AppError__c].isEmpty());
    }
}