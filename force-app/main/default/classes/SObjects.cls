public class SObjects {

	private List<SObject> records = new List<SObject>();


	// CONSTRUCTOR

	public SObjects(List<SObject> records) {
		this.records.addAll(records);
	}


	// PUBLIC

	public Map<Object, SObject> byUniqueField(String uniqueField) {
		Map<Object, SObject> result = new Map<Object, SObject>();

		for(SObject record : records) {
			result.put(record.get(uniqueField), record);
		}

		return result;
	}


	public SObjects changes(Map<Id, SObject> old, List<SObjectField> fields) {
		return changes(old, new ObjectList(fields).stringList());
	}


	public SObjects changes(Map<Id, SObject> old, SObjectField field) {
		return changes(old, ''+field);
	}


	public SObjects changes(Map<Id, SObject> old, String field) {
		return changes(old, new List<String>{ field });
	}


	public SObjects changes(Map<Id, SObject> old, List<String> fields) {
		List<SObject> result = new List<SObject>();

		for(SObject record : records) {
			for(String field : fields) {
				if(record.get(field) != old.get(record.Id).get(field)) {
					result.add(record);
					break;
				}
			}
		}

		return new SObjects(result);
	}


	public List<SObject> records() {
		return records;
	}

	// PRIVATE

	private Boolean hasValue(SObject record, SObjectField field) {
		return hasValue(record, ''+field);
	}


	private Boolean hasValue(SObject record, String field) {
		return (record.get(field) != null);
	}
}