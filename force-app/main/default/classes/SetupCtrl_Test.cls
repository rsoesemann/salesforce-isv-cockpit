@IsTest
private class SetupCtrl_Test {

    @IsTest
    private static void load() {

        // Setup
        Exception unexpectedException = null;
        SetupCtrl ctrl = null;


        // Exercise
        try {
            Test.setCurrentPage(Page.setup);
            ctrl = new SetupCtrl();
        }
        catch(Exception ex) {
            unexpectedException = ex;
        }


        // Verify
        System.assertEquals(null, unexpectedException);
        System.assertNotEquals(null, ctrl);
    }
}