delete [SELECT Id FROM AppError__c];
delete [SELECT Id FROM sfLma__Package_Version__c];
delete [SELECT Id FROM sfLma__License__c];
delete [SELECT Id FROM sfLma__Package__c];
delete [SELECT Id FROM Entitlement];
delete [SELECT Id FROM Account];

LmaPackage p1 = new LmaPackage().name('App A').ns('nsA');

LmaVersion v1 = new LmaVersion(p1).name('Summer 19').year(2019);
LmaVersion v2 = new LmaVersion(p1).name('Sprint 20').year(2020);
LmaVersion v3 = new LmaVersion(p1).name('Winter 21').year(2021);
LmaVersion v4 = new LmaVersion(p1).name('Spring 22').year(2022);

LmaLicense l1 = new LmaLicense(v1).org('00D000000000001');
LmaLicense l2 = new LmaLicense(new Account_t().name('Desla') ,v1).org('00D000000000002');
LmaLicense l3 = new LmaLicense(new Account_t().name('Universal Containers') ,v1).org('00D000000000003');
LmaLicense l4 = new LmaLicense(new Account_t().name('Peach') ,v1).org('00D000000000004');
LmaLicense l5 = new LmaLicense(new Account_t().name('Baimler') ,v1).org('00D000000000005');

p1.persist();

List<Object> exceptions = new List<Object>{ 'System.DmlException', 'System.NullPointerException', 'System.QueryException', 'System.LimitsException', 'System.AsyncException', 'MyCustomException'};
List<Object> classes = new List<Object>{ 'SetupController', 'AccountService', 'AsyncHandler', 'TriggerFramework', 'Bills' };
List<Object> pages = new List<Object>{ 'setup', 'home', 'licenseManager', 'setupV1'};

fflib_SObjectDomain.getTriggerEvent(AppErrors.class).disableAll();
for(Integer i=0; i<new Random().integer(400,800); i++) {
    new AppError((LmaLicense) new Random().value(new List<Object>{ l1,l2,l3,l4,l5 }))
        .exception((String) new Random().value(exceptions))
        .clazz((String) new Random().value(classes))
        .page((String) new Random().value(pages))
        .ver((LmaVersion) new Random().value(new List<Object>{ v1, v2, v3, v4 }));
}
p1.persist();