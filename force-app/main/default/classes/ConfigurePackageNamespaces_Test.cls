@IsTest
private class ConfigurePackageNamespaces_Test {

    @IsTest
    private static void execute() {

        // Setup
        Exception unexpectedException = null;

        ConfigurePackageNamespaces step = new ConfigurePackageNamespaces();


        // Exercise
        try {
            step.run();
        }
        catch(Exception ex) {
            unexpectedException = ex;
        }


        // Verify
        System.assertNotEquals(null, step.getStatus().getSeverity());
        System.assertEquals(null, unexpectedException);
    }
}