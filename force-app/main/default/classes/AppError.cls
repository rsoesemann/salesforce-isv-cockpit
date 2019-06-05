@IsTest
public class AppError extends DomainBuilder {

    private static final String TEMPLATE = 'Apex script unhandled trigger exception by user/organization: {0}/{1} \n\n' +
                                            '{2}.{3}Class: System.{3}Exception: Exception Message';
    private static Integer count = 0;

    public AppError(LmaLicense l) {
        super(AppError__c.SObjectType);

        String body = String.format(TEMPLATE, new List<String>{
                            '005500' + count++ + '00024uNj',
                            (String) l.record.get('sfLma__Subscriber_Org_ID__c'),
                            (String) l.lmaPackage.record.get('txt_Namespace__c'),
                            new Random().string(6),
                            new Random().string(4)
        });

        set(AppError__c.txl_FullMailBody__c, body);
    }
}