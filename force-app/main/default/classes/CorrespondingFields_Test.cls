@IsTest
private class CorrespondingFields_Test {

    @IsTest
    private static void happyPath() {

        // Setup & Exercise
        CorrespondingFields mapping = new CorrespondingFields(Contact.SObjectType, User.SObjectType);


        // Verify
        System.assertNotEquals(0, mapping.targetFields().size());
    }
}