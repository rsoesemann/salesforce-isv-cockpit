@IsTest
private class AddErrorInsights_Test {
    
    @IsTest
    private static void apiCalledAndResultsStored() {

        // Setup
        insert new Settings__c(txt_OpenAiApiKey__c = 'any');
        
        AppError__c e = (AppError__c) new AppError().persist();

        Test.startTest();
        new HttpMock()
                .post('/v1/completions', 
                        new OpenAiCompletions.Response().withChoice('Check the Power cord'), 200)
                .mock();


        // Exercise
        AddErrorInsights.execute(new List<Id>{ e.Id });
        Test.stopTest();

        
        // Verify
        e = [SELECT txl_Hints__c FROM AppError__c LIMIT 1];
        Assert.areEqual('Check the Power cord', e.txl_Hints__c);
    }
}