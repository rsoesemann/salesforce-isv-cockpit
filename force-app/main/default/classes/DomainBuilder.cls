public virtual class DomainBuilder {

    public SObjectType type;
    public SObject record;
    public Id id { private set; get {return record.Id;} }

    private Boolean isSetupObject;

    private Map<SObjectField, DomainBuilder> parentByRelationship = new Map<SObjectField, DomainBuilder>();
    private Map<SObjectField, Map<SObjectField, List<DomainBuilder>>> relationshipsToSync = new Map<SObjectField, Map<SObjectField, List<DomainBuilder>>>();

    private static fflib_SObjectUnitOfWork uow = initUnitOfWork();
    private static fflib_SObjectUnitOfWork setupUow = initUnitOfWork();
    private static Set<DomainBuilder> objects = new Set<DomainBuilder>();


    // CONSTRUCTORS

    public DomainBuilder(SObjectType type, Boolean isSetupObject) {
        this.type = type;
        this.record = type.newSObject(null, true);
        this.isSetupObject = isSetupObject;

        objects.add(this);
    }


    public DomainBuilder(SObjectType type) {
        this(type, false);
    }


    // PUBLIC

    public virtual SObject persist() {
        for(DomainBuilder obj: objects) {
            fflib_SObjectUnitOfWork tempUow = (obj.isSetupObject) ? setupUow : uow;

            if(obj.record.Id == null) {
                tempUow.registerNew(obj.record);
            }

            for(SObjectField rel: obj.parentByRelationship.keySet()) {
                DomainBuilder parent = obj.parentByRelationship.get(rel);
                tempUow.registerRelationship(obj.record, rel, parent.record);
            }
        }

        uow.commitWork();

        if(Test.isRunningTest()) {
            System.runAs(new User(Id = UserInfo.getUserId())) {
                setupUow.commitWork();
            }
        }
        else {
            System.debug(LoggingLevel.ERROR, 'PermissionSetAssignment can not be inserted (Mixed DML)');
        }

        uow = initUnitOfWork();
        setupUow = initUnitOfWork();

        objects.clear();

        return record;
    }


    // PROTECTED

    protected DomainBuilder setParent(SObjectField relationship, DomainBuilder parent) {

        // Note: The parent registered last always wins!
        DomainBuilder oldParent = parentByRelationship.get(relationship);

        // Note: Sometime we manually unregister parent that are set by default constructor
        if(parent != null) {
            parentByRelationship.put(relationship, parent);
        }

        if(oldParent != null && oldParent != parent) {
            oldParent.unregisterIncludingParents();
        }

        if(parent != null && !objects.contains(parent)) {
            parent.registerIncludingParents();
        }

        if(relationshipsToSync.containsKey(relationship)) {
            synchronize(relationship);
        }

        // Note: Return parent instead of this as we call this always from the parent
        return parent;
    }


    protected DomainBuilder set(String fieldName, Object value) {
        record.put(fieldName, value);
        return this;
    }


    protected DomainBuilder set(SObjectField field, Object value) {
        record.put(field, value);
        return this;
    }


    protected virtual void unregisterIncludingParents() {
        objects.remove(this);

        for(DomainBuilder parent : parentByRelationship.values()) {
            parent.unregisterIncludingParents();
        }
    }


    // PRIVATE

    private void registerIncludingParents() {
        if(record.Id == null) {
            objects.add(this);

            for(DomainBuilder parent: parentByRelationship.values()) {
                parent.registerIncludingParents();
            }
        }
    }


    private void synchronize(SObjectField sourceField) {
        for(SObjectField targetField: relationshipsToSync.get(sourceField).keySet()) {
            for(DomainBuilder obj : relationshipsToSync.get(sourceField).get(targetField)) {

                DomainBuilder parent = parentByRelationship.get(sourceField);
                obj.setParent(targetField, parent);
            }
        }
    }


    private static fflib_SObjectUnitOfWork initUnitOfWork() {
        return new fflib_SObjectUnitOfWork(new List<Schema.SObjectType>{
                            PermissionSetAssignment.SObjectType,
                            User.SObjectType,
                            Account.SObjectType,
                            Contact.SObjectType,
                            Opportunity.SObjectType,
                            OpportunityContactRole.SObjectType,
                            sfLma__Package__c.SObjectType,
                            sfLma__Package_Version__c.SObjectType,
                            sfLma__License__c.SObjectType,
                            AppError__c.SObjectType
        });
    }


    // INNER

    public class Random {

        public String string() {
            return string(8);
        }


        public String string(Integer length) {
            String result = '';

            for(Integer i=0; i<length; i++) {
                Integer pos = integer(25);
                result += 'abcdefghijklmnopqrstuvwxyz'.substring(pos, pos+1);
            }

            return result;
        }


        public Integer integer(Integer first, Integer last) {
            return Math.floor(Math.random() * ((last - first) + 1) + first).intValue();
        }


        public Integer integer(Integer max) {
            return integer(0, max);
        }


        public Boolean boolean() {
            return integer(0, 1) == 0;
        }


        public Object value(List<Object> values) {
            return values.get(integer(values.size()-1));
        }
    }
}