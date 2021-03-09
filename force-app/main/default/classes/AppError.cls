public class AppError extends DomainBuilder {

    public AppError() {
        this(new LmaLicense());
    }
    

    public AppError(LmaLicense l) {
        super(AppError__c.SObjectType);

        setParent(AppError__c.lkp_License__c, l);
        setParent(AppError__c.lkp_Package__c,l.version.lmaPackage);
        setParent(AppError__c.lkp_PackageVersion__c, l.version);
        setParent(AppError__c.lkp_Account__c, l.account);

        set(AppError__c.txt_UserId__c, new Random().id(User.SObjectType));
        set(AppError__c.txt_OrgId__c, l.record.get(sfLma__License__c.sfLma__Subscriber_Org_ID__c));
        set(AppError__c.txt_ExceptionType__c, (new Random().string()+'Exception').capitalize());
        set(AppError__c.txt_ApexClass__c, (new Random().string()+'.cls').capitalize());
        set(AppError__c.txt_VisualforcePage__c, (new Random().string()+'.page').capitalize());
    }
}