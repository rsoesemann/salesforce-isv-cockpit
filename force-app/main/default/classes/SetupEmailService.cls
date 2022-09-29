public with sharing class SetupEmailService extends SetupStep {

    private static final String DEVELOPER_NAME = 'AppErrorCockpit';
    private Id classId = [SELECT Id FROM ApexClass WHERE Name = 'ErrorMailReceiver' LIMIT 1].Id;

    // PUBLIC

    public EmailServicesAddress service { 
        get {
            for(EmailServicesAddress service : [SELECT LocalPart, EmailDomainName, Function.IsActive, FunctionId FROM EmailServicesAddress
                                                WHERE Function.FunctionName = :DEVELOPER_NAME AND Function.ApexClassId = :classId LIMIT 1]) {
                this.service = service;
            }
            return service;
        }
        private set; 
    }

    public Boolean isActive { 
        get { return (service != null && service.Function.IsActive); } private set; 
    }


    public List<Tokenizer__mdt> tokenizers { get { return new TokenizersSelector().allActiveInOrder(); } private set; }


    public override ApexPages.Message getStatus() {
        if(isActive) {
            String address = service.LocalPart + '@' + service.EmailDomainName;
            String link = '<em><a href="/lightning/setup/EmailToApexFunction/page?address=%2Femail-admin%2Fservices%2FdetailEmailServicesAddress.apexp%3Fid%3D' + service.Id + '">' + address + '</a></em>';
            String message = String.format('An Email Service is set up to receive error emails. Configure your Managed Packages to send errors to: {0}.<br/><br/>' +
                                           '{1} for {2} Email Tokenizers is available.',
                             new List<String>{ link, setupLink('m00', 'CustomMetadata', 'Custom Metadata'), ''+ tokenizers.size()});
            return new ApexPages.Message(ApexPages.Severity.CONFIRM, message);
        }
        else {
            return new ApexPages.Message(ApexPages.Severity.WARNING, 'An Email Service is required to allow the tool to receive app errors.');
        }
    }

    
    public override Boolean getShowButtonOnSuccess() {
        return true;
    }


    public override String buttonLabel() {
        return (isActive) ? 'Deactivate' : 'Activate';
    }


    public override PageReference run() {
        if(isActive) {
            deactivateServiceFunction(service.FunctionId);
        }
        else {
            createOrActivateServiceFunction();
            createOrActivateServiceAddress();
        }

        return currentPage();
    }


    // PRIVATE

    private void createOrActivateServiceFunction() {
        if(service == null) {
            soapApi('create',
                '<urn:type>EmailServicesFunction</urn:type>' +
                '<urn:fieldsToNull></urn:fieldsToNull>' +
                '<urn:ApexClassId>' +  classId + '</urn:ApexClassId>' +
                '<urn:IsActive>true</urn:IsActive>' +
                '<urn:FunctionName>' + DEVELOPER_NAME + '</urn:FunctionName>'
            );
        }
        else {
            soapApi('update', 
                '<urn:type>EmailServicesFunction</urn:type>' +
                '<urn:Id>' + service.FunctionId + '</urn:Id>' +
                '<urn:IsActive>true</urn:IsActive>'
            );
        }
    }
    

    private void createOrActivateServiceAddress() {
        if(service == null) {
            Id functionId = [SELECT Id FROM EmailServicesFunction WHERE FunctionName = :DEVELOPER_NAME].Id;

            soapApi('create',
                '<urn:type>EmailServicesAddress</urn:type>' +
                '<urn:FunctionId>' + functionId + '</urn:FunctionId>' +
                '<urn:DeveloperName>' + DEVELOPER_NAME + '</urn:DeveloperName>' +
                '<urn:IsActive>true</urn:IsActive>' +
                '<urn:LocalPart>app-error-inbox</urn:LocalPart>' +
                '<urn:RunAsUserId>' + UserInfo.getUserId() + '</urn:RunAsUserId>'
            );
        }
        else {
            soapApi('update',
                '<urn:type>EmailServicesAddress</urn:type>' +
                '<urn:Id>' + service.Id + '</urn:Id>' +
                '<urn:IsActive>true</urn:IsActive>'
            );
        }
    }
    

    private void deactivateServiceFunction(Id functionId) {
        soapApi('update',
            '<urn:type>EmailServicesFunction</urn:type>' +
            '<urn:Id>' + functionId + '</urn:Id>' +
            '<urn:IsActive>false</urn:IsActive>'
        );
    }
    

    private void soapApi(String operation, String sobjectXml) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/Soap/u/54.0');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml; charset=UTF-8');
        request.setHeader('SOAPAction', 'ignored');
        request.setBody('<?xml version="1.0" encoding="UTF-8"?><env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:urn="urn:partner.soap.sforce.com" xmlns:urn1="urn:sobject.partner.soap.sforce.com">' +
                        '<env:Header><SessionHeader xmlns="urn:partner.soap.sforce.com"><sessionId>' + UserInfo.getSessionId() + '</sessionId></SessionHeader></env:Header>' +
                        '<env:Body><urn:' + operation + '><urn:sObjects>' + sobjectXml + '</urn:sObjects></urn:' + operation + '></env:Body></env:Envelope>');
        
        HttpResponse response = new Http().send(request);
        if(response.getStatusCode() != 200) {
            throw new ApplicationException(response.getBody());
        }
    }
}