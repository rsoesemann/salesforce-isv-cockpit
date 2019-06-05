public class ObjectList {

	private List<Object> objects;

	// CONSTRUCTOR

	public ObjectList(List<Object> objects) {
		this.objects = objects;
	}


	// PUBLIC

	public List<String> stringList() {
		List<String> result = new List<String>();

		for(Object o : objects) {
			result.add(''+o);
		}

		return result;
	}
}