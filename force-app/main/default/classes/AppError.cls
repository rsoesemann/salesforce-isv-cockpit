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
        set(AppError__c.txl_FullMailBody__c, 'empty ');
    }

    public AppError exception(String value) {
        return (AppError) set(AppError__c.txt_ExceptionType__c, value);
    }

    public AppError clazz(String value) {
        return (AppError) set(AppError__c.txt_ApexClass__c, value);
    }

    public AppError page(String value) {
        return (AppError) set(AppError__c.txt_VisualforcePage__c, value);
    }

    public AppError ver(LmaVersion value) {
        setParent(AppError__c.lkp_PackageVersion__c, value);
        sfLma__Package_Version__c version = (sfLma__Package_Version__c) value.record;
        Date release = version.sfLma__Release_Date__c.addDays(new Random().integer(1, 250));
        set(AppError__c.dtm_RecordedDate__c, DateTime.newInstance(release.year(), release.month(), release.day()));
        return this;
    }
}