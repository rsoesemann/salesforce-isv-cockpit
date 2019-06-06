public with sharing class LmaLicense extends DomainBuilder {

    public LmaPackage lmaPackage;

    public LmaLicense(Account_t a) {
        this(a, new LmaVersion());
    }

    public LmaLicense(Account_t a, LmaVersion v) {
        super(sfLma__License__c.SObjectType);

        setParent(sfLma__License__c.sfLma__Account__c, a);
        setParent(sfLma__License__c.sfLma__Package_Version__c, v);

        set(sfLma__License__c.sfLma__Status__c, 'true');
        set(sfLma__License__c.sfLma__Seats__c, -1);
        set(sfLma__License__c.sfLma__Used_Licenses__c, 1);
        org('00D1X0000000R9E');
    }


    public LmaLicense(LmaVersion v) {
        this(new Account_t(), v);
    }


    public LmaLicense org(String value) {
        return (LmaLicense) set(sfLma__License__c.sfLma__Subscriber_Org_ID__c, value);
    }
}