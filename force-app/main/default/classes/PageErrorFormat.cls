public with sharing class PageErrorFormat extends ParseAppErrors.EmailFormat {

	public override String regex() {
		return '(005[A-Za-z0-9]{12})/(00D[A-Za-z0-9]{12})' +
				'[\\s]+' +
			    '.+/apex/(.+)__(.+)' +
				'[\\s]+' +
			    'caused by: (([^:]+):(.+))' +
				'[\\s]+' +
				'(Class\\.((.+)\\.([^:]+)([\\S\\s]+)))';
	}


	public override void populateFields(Matcher matcher, AppError__c error) {
		error.txt_UserId__c = matcher.group(1);
		error.txt_OrgId__c = matcher.group(2);
		error.txt_Namespace__c = matcher.group(3).toUpperCase();
		error.txt_VisualforcePage__c = matcher.group(4);
		error.txt_ExceptionType__c = matcher.group(6);
		error.txt_ExceptionMessage__c = matcher.group(7);
		error.txl_Stacktrace__c = matcher.group(8);
		error.txt_ApexClass__c = matcher.group(10);
	}
}