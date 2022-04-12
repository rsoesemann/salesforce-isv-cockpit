public with sharing class TriggerToken extends ParseAppErrors.Token {

	public override String regex() {
		return 'Trigger\\.(.+)\\.([^:]+)';
	}


	public override void populateFields(Matcher match, AppError__c error) {
		error.txt_Namespace__c = match.group(1);
		error.txt_ApexClass__c = match.group(2);
	}
}