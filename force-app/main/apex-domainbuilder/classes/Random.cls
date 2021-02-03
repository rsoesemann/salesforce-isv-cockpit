public class Random {

	private static Integer idCount = 0;

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


	public Decimal decimal(Decimal first, Decimal last) {
		return Math.random() * ((last - first) + 1) + first;
	}


	public Decimal decimal(Integer max) {
		return decimal(0, max);
	}


	public Integer integer(Integer first, Integer last) {
		return Math.floor(Math.random() * ((last - first) + 1) + first).intValue();
	}


    public Integer integer(Integer max) {
        return integer(0, max);
    }


    public Integer integer() {
        return integer(0, 214748364);
    }


	public Boolean boolean() {
		return integer(0, 1) == 0;
	}


	public Object value(List<Object> values) {
		return values.get(integer(values.size()-1));
	}


	public Id id(SObjectType type) {
		return id( type.getDescribe().getKeyPrefix() );
	}


	public Id id(String prefix) {
		idCount++;
		String zeros = '000000000000'.substring(0, 12 - String.valueOf(idCount).length());

		return Id.valueOf(prefix + zeros + idCount);
	}
}