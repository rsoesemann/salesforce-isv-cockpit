@IsTest
@TestVisible
private class Personas {

    public static User appAdmin() {
        User user = (User) User_t.standard().persist();
        assignPermSet(user, 'Admin');
        return user;
    }


    public static User appUser() {
        User user = (User) User_t.standard().persist();
        assignPermSet(user, 'User');
        return user;
    }


    private static void assignPermSet(User user, String name) {
        // Note: Hack by mmoyer that I need to understand and document
        System.runAs(user) {
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :name];
            insert new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id);
        }
    }
}
