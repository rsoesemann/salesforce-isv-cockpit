public with sharing class Tokenizer {

    private static final fflib_SObjectDescribe SCHEMA = fflib_SObjectDescribe.getDescribe(AppError__c.SObjectType);

    private Pattern regex;
    private List<SObjectField> fields = new List<SObjectField>();


    // CONSTRCUTOR

    public Tokenizer(Tokenizer__mdt record) {
        regex = Pattern.compile(record.txl_RegExp__c);
        
        for(String fieldValue : new List<String>{ record.txt_Group1Field__c, record.txt_Group2Field__c, record.txt_Group3Field__c, 
                                                  record.txt_Group4Field__c, record.txt_Group5Field__c}) {
            
            SObjectField field = (fieldValue != null) ? SCHEMA.getField(fieldValue) : null;
            if(field != null) {
                fields.add(field);
            }
        }
    }


    // PUBLIC

    public void execute(AppError__c error) {
        Matcher match = regex.matcher( error.txl_FullMailBody__c );

        if(match.find()) {
            for(Integer index=0; index<fields.size(); index++) {
                SObjectField field = fields.get(index);
                String value = match.group(index + 1).abbreviate(field.getDescribe().getLength());
                
                error.put(field, value);
            }
        }

        System.debug(LoggingLevel.ERROR, match);
    }


    public static List<Tokenizer> initialize() {
        List<Tokenizer> result = new List<Tokenizer>();

        for(Tokenizer__mdt record : new TokenizersSelector().allActiveInOrder()) {
            result.add(new Tokenizer(record));
        }
        
        return result;
    }
}