delete [SELECT Id FROM AppError__c];
delete [SELECT Id FROM sfLma__Package_Version__c];
delete [SELECT Id FROM sfLma__License__c];
delete [SELECT Id FROM sfLma__Package__c];
delete [SELECT Id FROM Account];

Account_t customer1 = new Account_t().name('Customer 1');
Account_t customer2 = new Account_t().name('Customer 2');

LmaPackage appA = new LmaPackage().name('App A').ns('nsA')
                    .add(new LmaVersion().name('v1')
                                        .add(new LmaLicense(customer1)))

                    .add(new LmaVersion().name('v2')
                                        .add(new LmaLicense(customer1))
                                        .add(new LmaLicense(customer2)));

LmaPackage appB = new LmaPackage().name('App B').ns('nsB')
                    .add(new LmaVersion().name('Summer 19')
                                        .add(new LmaLicense(customer2)))

                    .add(new LmaVersion().name('Winter 18')
                                        .add(new LmaLicense(customer1))
                                        .add(new LmaLicense(customer2)));
appA.persist();

StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = 'error_mails_txt'];

List<AppError__c> errors = new List<AppError__c>();
for(String mail : resource.Body.toString().split('&')) {
    errors.add(new AppError__c(txl_FullMailBody__c = mail));
}
insert errors;