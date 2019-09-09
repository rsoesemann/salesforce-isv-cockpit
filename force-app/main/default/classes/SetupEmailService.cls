public with sharing class SetupEmailService extends SetupStep {

    private static final String FUNCTION_NAME = 'App Error Inbox';
    private Id classId;


    // PUBLIC

    public override ApexPages.Message getStatus() {
        classId = [SELECT Id FROM ApexClass WHERE Name = 'ErrorMailReceiver' LIMIT 1].Id;

        List<EmailServicesAddress> existing = [SELECT LocalPart, EmailDomainName, Id FROM EmailServicesAddress
                                               WHERE Function.FunctionName = :FUNCTION_NAME AND Function.ApexClassId = :classId LIMIT 1];

        if(existing.isEmpty()) {
            return new ApexPages.Message(ApexPages.Severity.WARNING, 'An Email Service is required to allow the tool to receive app errors.');
        }
        else {
            String address = existing[0].LocalPart + '@' + existing[0].EmailDomainName;
            String link = '<em><a href="/lightning/setup/EmailToApexFunction/page?address=%2Femail-admin%2Fservices%2FdetailEmailServicesAddress.apexp%3Fid%3D' + existing[0].Id + '">' + address + '</a></em>';
            return new ApexPages.Message(ApexPages.Severity.CONFIRM, 'An Email Service is set up to receive app errors. Make all your Managed Packages send errors to: <br/>' + link);
        }
    }


    public override String buttonLabel() {
        return 'Execute';
    }


    public override PageReference run() {
        try {
            createSObject('<urn1:type>EmailServicesFunction</urn1:type>' +
                                '<urn1:fieldsToNull></urn1:fieldsToNull>' +
                                '<urn1:ApexClassId>' +  classId + '</urn1:ApexClassId>' +
                                '<urn1:IsActive>true</urn1:IsActive>' +
                                '<urn1:FunctionName>' + FUNCTION_NAME +'</urn1:FunctionName>' +
                                '<urn1:AttachmentOption>None</urn1:AttachmentOption>');

            Id functionId = [SELECT Id FROM EmailServicesFunction WHERE FunctionName = :FUNCTION_NAME AND ApexClassId = :classId].Id;
            createSObject('<urn1:type>EmailServicesAddress</urn1:type>' +
                                '<urn1:FunctionId>' + functionId + '</urn1:FunctionId>' +
                                '<urn1:DeveloperName>AppErrorInbox</urn1:DeveloperName>' +
                                '<urn1:IsActive>true</urn1:IsActive>' +
                                '<urn1:LocalPart>app-error-inbox</urn1:LocalPart>' +
                                '<urn1:RunAsUserId>' + UserInfo.getUserId() + '</urn1:RunAsUserId>');
        }
        catch(Exception ex) {
            ApexPages.addMessages(ex);
        }

        return null;
    }


    // PRIVATE

    private HTTPResponse createSObject(String fragment) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/Soap/u/45.0');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml; charset=UTF-8');
        request.setHeader('SOAPAction', 'ignored');
        request.setBody('<?xml version="1.0" encoding="UTF-8"?><env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:urn="urn:partner.soap.sforce.com" xmlns:urn1="urn:sobject.partner.soap.sforce.com"><env:Header><SessionHeader xmlns="urn:partner.soap.sforce.com"><sessionId>' + UserInfo.getSessionId() + '</sessionId></SessionHeader></env:Header><env:Body><urn:create><urn:sObjects>' +
                            + fragment + '</urn:sObjects></urn:create></env:Body></env:Envelope>');

        return new Http().send(request);
    }
}