@IsTest
private class SetupArchiveErrors_Test {

    @IsTest
    private static void happyPath() {

        // Setup
        Exception unexpectedException = null;
        Test.setMock(WebServiceMock.class, new MdApiMock());

        SetupArchiveErrors step = new SetupArchiveErrors();


        // Exercise
        try {
            step.doRun();
        }
        catch(Exception ex) {
            unexpectedException = ex;
        }


        // Verify
        System.assertNotEquals(null, step.getSeverity());
        System.assertNotEquals(null, step.getMessage());
        System.assertNotEquals(null, step.buttonLabel());
        System.assertEquals(null, unexpectedException);
    }
    
    
    // HELPER

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public class MdApiMock implements WebServiceMock {
        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint,
                            String soapAction, String requestName, String responseNS, String responseName, String responseType) {
            response.put('response_x', '<createResponse><result><success>true</success></result></createResponse>');
        }
    }
}