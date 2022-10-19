trigger AppErrors on AppError__c (before insert, after insert, before update) {
    fflib_SObjectDomain.triggerHandler(AppErrors.class);
}