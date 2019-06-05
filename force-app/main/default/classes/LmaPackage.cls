@IsTest
public class LmaPackage extends DomainBuilder {

    private static Integer count = 1;

    public LmaPackage() {
        super(sfLma__Package__c.SObjectType);

        set(sfLma__Package__c.Name, 'App ' + count++);
        ns('ns_' + count++);
        set(sfLma__Package__c.sfLma__Release_Date__c, System.today());
        set(sfLma__Package__c.sfLma__Package_ID__c, '033A0000000' + count++ + '000IAA');
    }

    public LmaPackage ns(String value) {
        return (LmaPackage) set(sfLma__Package__c.txt_Namespace__c, value);
    }

    public LmaPackage add(LmaVersion v) {
        return (LmaPackage) v.setParent(sfLma__Package_Version__c.sfLma__Package__c, this);
    }
}