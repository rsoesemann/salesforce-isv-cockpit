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
            ctrl = new MySetupCtrl();
        }
        catch(Exception ex) {
            unexpectedException = ex;
        }


        // Verify
        System.assertEquals(null, unexpectedException);
        System.assertNotEquals(null, ctrl);
        System.assertEquals(2, ctrl.steps().size());
        System.assertEquals(50, ctrl.getProgress());
        System.assertEquals(ctrl, ctrl.controller);
    }


    // HELPER

    private class MySetupCtrl extends SetupCtrl {
        public override List<SetupStep> steps() { return new List<SetupStep>{ new SuccessStep(), new WarningStep() }; }
    }


    private class SuccessStep extends SetupStep {
        public override ApexPages.Message getStatus() { return new ApexPages.Message(ApexPages.severity.CONFIRM, ''); }
        public override PageReference run() { return null; }
        public override String buttonLabel() { return null;  }
    }


    private class WarningStep extends SetupStep {
        public override ApexPages.Message getStatus() { return new ApexPages.Message(ApexPages.severity.WARNING, ''); }
        public override PageReference run() { return null; }
        public override String buttonLabel() { return null;  }
    }
}