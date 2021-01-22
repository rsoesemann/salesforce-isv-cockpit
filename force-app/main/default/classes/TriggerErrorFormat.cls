public class TriggerErrorFormat extends ParseAppErrors.EmailFormat {

	public override String regex() {
		return '(005[A-Za-z0-9]{12})/(00D[A-Za-z0-9]{12})' +
				'[\\s\\S]+' +
				'caused by: ([^:]+): (.+)' +
				'[\\s\\S]+' +
				'Trigger\\.(.+)\\.([^:]+)';
	}


	public override void populateFields(Matcher match, AppError__c error) {
		error.txt_UserId__c = match.group(1);
		error.txt_OrgId__c = match.group(2);
		error.txt_ExceptionType__c = match.group(3);
		error.txt_ExceptionMessage__c = match.group(4).abbreviate(255);
		error.txt_Namespace__c = match.group(5);
		error.txt_ApexClass__c = match.group(6);
	}
}