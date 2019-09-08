public class TriggerErrorFormat extends ParseAppErrors.EmailFormat {

	public override String regex() {
		return '(005[A-Za-z0-9]{12})/(00D[A-Za-z0-9]{12})' +
				'[\\s\\S]+' +
				'caused by: (([^:]+):(.+))' +
				'[\\s]+' +
				'(Trigger\\.((.+)\\.([^:]+)([\\S\\s]+)))';
	}


	public override void populateFields(Matcher matcher, AppError__c error) {
		error.txt_UserId__c = matcher.group(1);
		error.txt_OrgId__c = matcher.group(2);
		error.txt_ExceptionType__c = matcher.group(4);
		error.txt_ExceptionMessage__c = matcher.group(5);
		error.txl_Stacktrace__c = matcher.group(6);
		error.txt_Namespace__c = matcher.group(8);
		error.txt_ApexClass__c = matcher.group(9);
	}
}