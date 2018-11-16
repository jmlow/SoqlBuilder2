public interface ISoqlable {
	String toSoql();
	String toSoql(SoqlOptions options);
}