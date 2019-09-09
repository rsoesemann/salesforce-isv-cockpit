@IsTest
private class SetupEmailService_Test {

    @IsTest
    private static void execute() {

        // Setup
        Exception unexpectedException = null;
        Test.setMock(WebServiceMock.class, new MdApiMock());

        SetupEmailService step = new SetupEmailService();


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

    public class MdApiMock implements WebServiceMock {
        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint,
                            String soapAction, String requestName, String responseNS, String responseName, String responseType) {
            response.put('response_x', '<createResponse><result><success>true</success></result></createResponse>');
        }
    }
}