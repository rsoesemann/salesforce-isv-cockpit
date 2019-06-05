@IsTest
private class ConfigurationCtrl_Test {

    @IsTest
    private static void load() {

        // Setup
        Exception unexpectedException = null;
        ConfigurationCtrl ctrl = null;


        // Exercise
        try {
            Test.setCurrentPage(Page.Configuration);
            ctrl = new ConfigurationCtrl();
        }
        catch(Exception ex) {
            unexpectedException = ex;
        }


        // Verify
        System.assertEquals(null, unexpectedException);
        System.assertNotEquals(null, ctrl);
    }

}