public class SoqlOptions {
		public Boolean escapeSingleQuotes {get; private set;} {escapeSingleQuotes = true;}
		public Boolean wildcardStringsInLikeOperators {get; private set;} {wildcardStringsInLikeOperators = false;}
		public static final SoqlOptions DEFAULT_OPTIONS = new SoqlOptions();
		public SoqlOptions escapeSingleQuotes(Boolean value) {this.escapeSingleQuotes = value; return this;}
		public String escapeSingleQuotes(String value) {
			if(this.escapeSingleQuotes) String.escapeSingleQuotes(value);
			return value;
		}
		public SoqlOptions wildcardStringsInLikeOperators(Boolean value) {this.wildcardStringsInLikeOperators = value; return this;}
		public String wildcardStringsInLikeOperators(String value) {
			if(this.wildcardStringsInLikeOperators) {
				if(!value.startsWith('%')) value = '%' + value;
				if(!value.endsWith('%')) value = value + '%';
			}
			return value;
		}
	}