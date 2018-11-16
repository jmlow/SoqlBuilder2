public class SoqlUtils {
	public static String toLiteral(final Object value) {return toLiteral(value, null);}
	public static String toLiteral(final Object value, final SoqlOptions options) {
		if(options == null) options = SoqlOptions.DEFAULT_OPTIONS;
		String literal = '';
		if(value == null) literal += 'null';
		else if(value instanceOf ISoqlable) return ((ISoqlable)value).toSoql(options);
		else if(
			value instanceOf Boolean ||
			value instanceOf Decimal ||
			value instanceOf Double ||
			value instanceOf Integer ||
			value instanceOf Long
		) {
			literal += value;
		//TODO: Looking at the original package, the next 2 lines seem suspect in regards to the original Date/Time bug. I made changes, but haven't tested.
		} else if(value instanceOf Date) literal += ((Date)value).format(); 
		else if(value instanceOf Datetime) literal += ((Datetime)value).format('yyyy-MM-dd') + 'T' + ((Datetime)value).format('hh:mm:ss', 'UTC') + 'Z';
		else if(value instanceOf Id || value instanceOf String) {
			literal = (String)value;
			if(options.escapeSingleQuotes == true) literal = String.escapeSingleQuotes(literal);
			literal = '\'' + literal + '\'';
		}
		else throw new IllegalArgumentException('Invalid value! Value must be null, a primitive, or implement ISoqlable!');
		return literal;
	}
	public static List<String> toLiteral(final List<Object> values) {return toLiteral(values,null);}
	public static List<String> toLiteral(final List<Object> values, final SoqlOptions options) {
		final List<String> literals = new List<String>();
		if(values != null && values.size() > 0) {
			for(Object value : values) {
				literals.add(toLiteral(value,options));
			}
		}
		return literals;
	}
}
