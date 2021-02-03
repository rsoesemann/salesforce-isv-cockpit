public with sharing class LmaLicense extends DomainBuilder {

    private static Integer count = 0;

    public Account_t account;
    public LmaVersion version;

    public LmaLicense() {
        this(new Account_t());
    }

    public LmaLicense(Account_t a) {
        this(a, new LmaVersion());
    }

    public LmaLicense(Account_t a, LmaVersion v) {
        super(sfLma__License__c.SObjectType);

        setParent(sfLma__License__c.sfLma__Account__c, a);
        account = a;
        
        setParent(sfLma__License__c.sfLma__Package_Version__c, v);
        setParent(sfLma__License__c.sfLma__Package__c, v.lmaPackage);
        version = v;

        set(sfLma__License__c.sfLma__Subscriber_Org_ID__c, new Random().id(Organization.SObjectType));
        set(sfLma__License__c.sfLma__Status__c, 'true');
        set(sfLma__License__c.sfLma__Seats__c, -1);
        set(sfLma__License__c.sfLma__Used_Licenses__c, 1);
        org(new Random().id('00D'));
    }

    public LmaLicense(LmaVersion v) {
        this(new Account_t(), v);
    }

    public LmaLicense org(String value) {
        return (LmaLicense) set(sfLma__License__c.sfLma__Subscriber_Org_ID__c, value);
    }

    public LmaLicense add(AppError e) {
        return (LmaLicense) e.setParent(AppError__c.lkp_License__c, this);
    }
}