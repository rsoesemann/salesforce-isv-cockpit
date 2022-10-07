global with sharing class ErrorMailReceiver implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail mail, Messaging.InboundEnvelope envelope) {
        insert as system new AppError__c(txl_FullMailBody__c = mail.plainTextBody);

        return new Messaging.InboundEmailResult();
    }
}