@IsTest
private class SetupPackageNamespaces_Test {

    @IsTest
    private static void execute() {

        // Setup
        Exception unexpectedException = null;

        new LmaPackage().ns(null).persist();

        SetupPackageNamespaces step = new SetupPackageNamespaces();


        // Exercise
        try {
            step.run();
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
}