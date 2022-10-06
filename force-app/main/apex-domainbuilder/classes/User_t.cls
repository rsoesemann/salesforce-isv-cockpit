public with sharing class User_t extends DomainBuilder {

	private static final Id STANDARD_USER = [SELECT Id FROM Profile WHERE UserType = 'Standard' AND Name LIKE '%Standard%' ORDER BY CreatedDate ASC LIMIT 1].Id;
	private static final Id SYSADMIN = [SELECT Id FROM Profile WHERE UserType = 'Standard' AND  PermissionsPrivacyDataAccess = true ORDER BY CreatedDate ASC LIMIT 1].Id;

	public User_t(Id profileId) {
		super(User.SObjectType);

		String name = new Random().string();
		set(User.Alias, 'alias');
		set(User.Email, name + '@scott.com');
		set(User.EmailEncodingKey, 'UTF-8');
		set(User.FirstName, 'Jill');
		set(User.Lastname, 'Scott');
		set(User.languagelocalekey, 'en_US');
		set(User.localesidkey, 'en_US');
		set(User.timezonesidkey, 'America/Los_Angeles');
		set(User.isActive, true);
		set(User.username, name + '@scott.com');
		set(User.profileId, profileId);
		set(User.UserPermissionsSFContentUser, false);
	}


	public static User_t standard() {
		return new User_t(STANDARD_USER);
	}


	public static User_t sysadmin() {
		return new User_t(SYSADMIN);
	}
}