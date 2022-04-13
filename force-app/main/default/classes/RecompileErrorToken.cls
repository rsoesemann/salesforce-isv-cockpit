public with sharing class RecompileErrorToken extends ParseAppErrors.Token {

    public override String regex() {
        return 'Dependent class is invalid and needs recompilation.+\\n(?:Class )([^.]+)\\.([^ ]+) : ([^:]+)$';
    }


    public override void populateFields(Matcher match, AppError__c error) {
        error.txt_Namespace__c = match.group(1);
        error.txt_ApexClass__c = match.group(2);
        error.txt_ExceptionType__c = '_InvalidDependentClassNeedsRecompile';
        error.txt_ExceptionMessage__c = abbreviate(match.group(3), 255);
    }
}
