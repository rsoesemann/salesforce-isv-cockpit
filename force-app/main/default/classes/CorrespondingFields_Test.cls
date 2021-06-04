@IsTest
private class CorrespondingFields_Test {

    @IsTest
    private static void happyPath() {

        // Setup & Exercise
        CorrespondingFields mapping = new CorrespondingFields(Contact.SObjectType, Account.SObjectType);


        // Verify
        System.assertNotEquals(0, mapping.targetFields().size());
        System.assert(mapping.targetFields().contains(Account.Phone), mapping.targetFields());
        System.assertEquals(Contact.Phone, mapping.sourceField(Account.Phone));
    }
}