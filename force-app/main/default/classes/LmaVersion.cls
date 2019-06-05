@IsTest
public class LmaVersion extends DomainBuilder {

    private static Integer count = 1;
    public LmaPackage lmaPackage;

    public LmaVersion() {
        this(new LmaPackage());
    }

    public LmaVersion(LmaPackage p) {
        super(sfLma__Package_Version__c.SObjectType);
        setParent(sfLma__Package_Version__c.sfLma__Package__c, p);

        lmaPackage = p;

        set(sfLma__Package_Version__c.Name, count++ + '.0');
        set(sfLma__Package_Version__c.sfLma__Version__c, count++ + '.0');
        set(sfLma__Package_Version__c.sfLma__Release_Date__c, System.today());
        set(sfLma__Package_Version__c.sfLma__Version_ID__c, '04tA0000000' + count++ + '000IAA');
    }
}