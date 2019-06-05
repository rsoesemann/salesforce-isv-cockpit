@IsTest
private class ErrorMailReceiver_Test {

    @IsTest
    private static void receive(){

        // Setup
        Messaging.InboundEmail mail = new Messaging.InboundEmail();
        mail.fromAddress ='info@salesforce.com';
        mail.subject = 'Ignored';
        mail.plainTextBody = 'MailBody';


        // Exercise
        new ErrorMailReceiver().handleInboundEmail(mail, new Messaging.InboundEnvelope());


        // Verify
        System.assertEquals(mail.plainTextBody , [SELECT txl_FullMailBody__c FROM AppError__c LIMIT 1].txl_FullMailBody__c);
    }
}