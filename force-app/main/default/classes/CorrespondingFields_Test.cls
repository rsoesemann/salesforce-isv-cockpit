@IsTest
private class CorrespondingFields_Test {

    @IsTest
    private static void happyPath() {

        // Setup & Exercise
        CorrespondingFields mapping = new CorrespondingFields(Contact.SObjectType, Account.SObjectType);


        // Verify
        System.assertNotEquals(0, mapping.targetFields().size());
        System.assert(mapping.targetFields().contains(Account.Name), mapping.targetFields());
        System.assertEquals(Contact.Name, mapping.sourceField(Account.Name));
    }
}