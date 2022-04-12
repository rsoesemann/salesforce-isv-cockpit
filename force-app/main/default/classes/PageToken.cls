public with sharing class PageToken extends ParseAppErrors.Token {

    public override String regex() {
		return '.+/apex/(.+)__(.+)';
	}


	public override void populateFields(Matcher match, AppError__c error) {
		error.txt_Namespace__c = match.group(1).toUpperCase();
		error.txt_VisualforcePage__c = match.group(2);
	}
}