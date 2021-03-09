public class LmaVersion extends DomainBuilder {

    private static Integer count = 0;

    public LmaPackage lmaPackage;

    public LmaVersion() {
        this(new LmaPackage());
    }

    public LmaVersion(LmaPackage p) {
        super(sfLma__Package_Version__c.SObjectType);
        setParent(sfLma__Package_Version__c.sfLma__Package__c, p);
        lmaPackage = p;

        name('v.1');
        set(sfLma__Package_Version__c.sfLma__Version__c, '1');
        set(sfLma__Package_Version__c.sfLma__Release_Date__c, System.today());
        id(new Random().id('04t'));
    }

    public LmaVersion name(String value) {
        return (LmaVersion) set(sfLma__Package_Version__c.Name, value);
    }

    public LmaVersion id(String value) {
        return (LmaVersion) set(sfLma__Package_Version__c.sfLma__Version_ID__c, value);
    }

    public LmaVersion add(LmaLicense l) {
        l.setParent(sfLma__License__c.sfLma__Package_Version__c, this);
        return this;
    }
}