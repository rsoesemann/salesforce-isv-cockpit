public class CorrespondingFields {
	
	private final Map<String, SObjectType> sources;
	private final SObjectType target;
	private final Map<SObjectType, Map<SObjectField, SObjectField>> fieldMap;
	
	private Set<String> toIgnore = new Set<String>();
	
	
	// CONSTRUCTOR

	public CorrespondingFields(Map<String, SObjectType> sourceTypes, SObjectType targetType, Set<String> toIgnore) {
		sources = sourceTypes;
		target = targetType;
		this.toIgnore = toIgnore;
		fieldMap = fieldMap();
	}

	public CorrespondingFields(Map<String, SObjectType> sourceTypes, SObjectType targetType) {
		this(sourceTypes, targetType, new Set<String>());
	}


	public CorrespondingFields(SObjectType sourceType, SObjectType targetType, Set<String> toIgnore) {
		// Note: If not type code is found null is returned
		this(new Map<String, SObjectType>{ null => sourceType }, targetType, toIgnore);
	}


	public CorrespondingFields(SObjectType sourceType, SObjectType targetType) {
		this(sourceType, targetType, new Set<String>());
	}

	
	// PUBLIC
	
	public Set<SObjectField> targetFields(SObjectType sourceType) {
		return (fieldMap.containsKey(sourceType)) ? fieldMap.get(sourceType).keySet() : new Set<SObjectField>();
	}


	public Set<SObjectField> targetFields() {
		Set<SObjectField> result = new Set<SObjectField>();
		
		for(Map<SObjectField, SObjectField> typeMap : fieldMap.values()) {
			result.addAll(typeMap.keySet());
		}
		
		return result;
	}


	public Set<SObjectField> sourceFields(SObjectType sourceType) {
		Set<SObjectField> result = new Set<SObjectField>();
		
		if(fieldMap.containsKey(sourceType)) {
			result.addAll(fieldMap.get(sourceType).values());
		}
		
		return result;
	}


	public SObjectField sourceField(SObjectType sourceType, SObjectField targetField) {
		return (fieldMap.containsKey(sourceType)) ? fieldMap.get(sourceType).get(targetField) : null;
	}


	public SObjectField sourceField(SObjectField targetField) {
		for(Map<SObjectField, SObjectField> typeMap : fieldMap.values()) {
			if(typeMap.containsKey(targetField)) {
				return typeMap.get(targetField);
			}
		}
		
		return null;
	}


	public Map<SObjectField, SObjectField> targetSourceMapping(SObjectType sourceType) {
		Map<SObjectField, SObjectField> result = new Map<SObjectField, SObjectField>();
		
		if(fieldMap.containsKey(sourceType)) {
			result.putAll(fieldMap.get(sourceType));
		}
		
		return result;
	}

	
	// PRIVATE
	
	private Map<SObjectType, Map<SObjectField, SObjectField>> fieldMap() {
		Map<SObjectType, Map<SObjectField, SObjectField>> result = new Map<SObjectType, Map<SObjectField, SObjectField>>();
		
		for(SObjectField targetField : relevantTargetFields()) {
			String typeCode = firstTypeCode(targetField);
			SObjectType sourceType = sources.get(typeCode);
			
			if(sourceType != null) {
				DescribeSobjectResult describe = sourceType.getDescribe();
				String field = (typeCode == null) ? stripNs(targetField) : stripNs(targetField).substringAfter(typeCode + '_'); 
				
				Boolean noFieldFound = true;
				
				for(String candidateName : new List<String>{ field, standard(field) }) {
					SObjectField sourceField = describe.fields.getMap().get(candidateName);
	 	
					if(sourceField != null) {
						if(!result.containsKey(sourceType)) {
							result.put(sourceType, new Map<SObjectField, SObjectField>());
						}
						
						result.get(sourceType).put(targetField, sourceField);
						
						noFieldFound = false;
						break;
					}
				}
				
				// Note: Only fields with type code must have a corresponding source field
				if(typeCode != null && noFieldFound) {
					new ApplicationException('No source field ' + field + ' found for target field ' + targetField).throwAuraHandled();
				}
			}
		}
		
		return result;
	}


	private List<SObjectField> relevantTargetFields() {
		List<SObjectField> result = new List<SObjectField>();
		
		for(SObjectField field : target.getDescribe().fields.getMap().values()) {
			DescribeFieldResult describe = field.getDescribe();
			
			if((describe.isNameField() || describe.isCustom()) && dontIgnore(field)) {
				result.add(field);
			}
		}
		
		return result;
	}


	private String firstTypeCode(SObjectField field) {
		for(String fragment : stripNs(field).split('_')) {
			for(String typeCode : sources.keySet()) {
				if(fragment.equals(typeCode)) {
					return typeCode;
				}
			}
		}
		
		return null;
	}


	private String standard(String fieldName) {
		return fieldName.removeEnd('__c');
	}


	private String ns(String prefix, String fieldName) {
		return prefix + '__' + fieldName;
	}


	private String stripNs(SObjectField field) {
		return String.valueOf(field).replaceFirst('^.*?(?=__.+?__c)', '').removeStart('__');
	}


	private Boolean dontIgnore(SObjectField field) {
		return !(toIgnore.contains(''+field) || toIgnore.contains(field.getDescribe().getLocalName()));
	}
}