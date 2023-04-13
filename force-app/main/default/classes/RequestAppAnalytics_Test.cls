@IsTest
private class RequestAppAnalytics_Test {

    @IsTest
    private static void activate() {
        
        // Setup
        LmaPackage p = new LmaPackage()
                                .ns('any').id('033xx00SIMsmall');
        LmaVersion v = new LmaVersion(p);
        new LmaLicense(v).org('');
        sfLma__Package__c pck = (sfLma__Package__c) p.persist();


        // Exercise
        new RequestAppAnalytics().execute(null);


        // Verify
        System.assert(RequestAppAnalytics.requests[0].PackageIds.startsWith(pck.sfLma__Package_ID__c));
    }
}