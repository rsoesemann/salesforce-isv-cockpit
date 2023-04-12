@IsTest
private class AddErrorInsights_Test {
    
    @IsTest
    private static void apiCalledAndResultsStored() {

        // Setup
        insert new Settings__c(txt_OpenAiApiKey__c = 'any');

        AppError__c e = (AppError__c) new AppError().email(
                                'Apex script unhandled exception by user/organization: 005500000024uNj/00D000000000001\n\n' +
                                'Failed to process batch for class \'Namespace.MyBatchOb\' for job id \'7073X00009N7cij\'\n\n' +
                                'caused by: System.NullPointerException: Attempt to de-reference a null object\n\n' + 
                                ' External entry point')
                            .persist();
        Test.startTest();
        
        new HttpMock()
                .post('/v1/completions', 
                        new OpenAiCompletions.Response()
                                .withChoice('Check the Power cord'), 200)
                .mock();


        // Exercise
        AddErrorInsights.execute(new List<Id>{ e.Id });
        Test.stopTest();

        
        // Verify
        e = [SELECT txl_Insights__c FROM AppError__c LIMIT 1];
        Assert.areEqual('Check the Power cord', e.txl_Insights__c);
    }
}