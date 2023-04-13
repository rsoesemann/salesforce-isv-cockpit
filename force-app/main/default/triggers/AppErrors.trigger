trigger AppErrors on AppError__c (before insert, before update) {
    Triggers.prepare()
                .beforeInsert()
                    .bind( new ParseAppErrors() )
                .beforeUpdate()
                    .bind( new ParseAppErrors() )
                .execute();
}