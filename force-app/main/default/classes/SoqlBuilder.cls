global with sharing class SoqlBuilder implements ISoqlable {
	//Enums
	enum UnitOfTime {
		DAY,
		WEEK,
		MONTH,
		QUARTER,
		YEAR,
		FISCAL_QUARTER,
		FISCAL_YEAR
	}
	enum FieldOperator {
		//Aggregate Operators
		AVERAGE, //AVERAGE()
		COUNT, //COUNT()
		MAX, //MAX()
		MIN, //MIN()
		SUM, //SUM()
		//Translation Operator
		TO_LABEL, //toLabel()
		//Grouping Operator
		GROUPING //GROUPING()
	}
	enum ConditionOperator {
		//Field Operators
		EQUALS, //=
		NOT_EQUALS, //!=
		LESS_THAN, //<
		LESS_THAN_OR_EQUAL_TO, //<=
		GREATER_THAN, //>
		GREATER_THAN_OR_EQUAL_TO, //>=
		LIKEx, //LIKE
		//Set Operators
		INCLUDES, //INCLUDES
		EXCLUDES, //EXCLUDES
		INx, //IN
		NOT_IN //NOT IN
	}
	enum ClauseOperator {
		ANDx, //AND
		ORx //OR
	}
	enum FilterScope {
		DELEGATED, //Delegated
		EVERYTHING, //Everything
		MINE, //Mine
		MINEANDMYGROUPS, //MineAndMyGroups
		MY_TERRITORY, //My_Territory
		MY_TEAM_TERRITORY, //My_Team_Territory
		TEAM //Team
	}
	enum NullsOrder {
		NULLS_FIRST, //NULLS FIRST
		NULLS_LAST //NULLS LAST
	}
	enum SortOrder {
		ASCENDING, //ASC
		DESCENDING //DESC
	}

	//Exceptions
	class IllegalStateException extends Exception {}
	class IndexOutOfBoundsException extends Exception {}
	class InvalidCharacterStringException extends Exception {}
	class NumberFormatException extends Exception {}

	//Interfaces
	interface ICondition extends ISoqlable {}
	interface INestableCondition extends ICondition {
		INestableCondition add(ICondition condition);
	}
	interface ISObjectComparator {
		Integer compare(SObject record1, SObject record2);
	}

	interface IObjectComparator {
		Integer compare(Object object1, Object object2);
	}

	//Classes
	class Field implements ISoqlable{
		public String name {get; set;} {name = null;}
		public String alias {get; set;} {alias = null;}
		public FieldOperator operator {get; private set;} {operator = null;}
		public Field(String name) {
			if(String.isBlank(name)) throw new IllegalArgumentException('Field name cannot be null!');
			this.name = name;
		}
		public Field(String name, String alias) {this(name); this.alias = alias;}
		public Field average() {this.operator = FieldOperator.AVERAGE; return this;}
		public Field count() {this.operator = FieldOperator.COUNT; return this;}
		public Field max() {this.operator = FieldOperator.MAX; return this;}
		public Field min() {this.operator = FieldOperator.MIN; return this;}
		public Field sum() {this.operator = FieldOperator.SUM; return this;}
		public Field toLabel() {this.operator = FieldOperator.TO_LABEL; return this;}
		public Field grouping() {this.operator = FieldOperator.GROUPING; return this;}
		public String toSoql() {return this.toSoql(null);}
		public String toSoql(SoqlOptions options) {
			if(options == null) options = SoqlOptions.DEFAULT_OPTIONS;
			String soql;
			switch on operator {
				when AVERAGE {soql = 'AVERAGE(' + this.name + ')';}
				when COUNT {soql = 'COUNT(' + this.name + ')';}
				when MAX {soql = 'MAX(' + this.name + ')';}
				when MIN {soql = 'MIN(' + this.name + ')';}
				when SUM {soql = 'SUM(' + this.name + ')';}
				when TO_LABEL {soql = 'toLabel(' + this.name + ')';}
				when GROUPING {soql = 'GROUPING(' + this.name + ')';}
				when else {soql = this.name;}
			}
			if(this.alias != null) soql += ' ' + this.alias;
			return soql;
		}
	}
	class Fromx implements ISoqlable {
		public String fromObject {get; set;}
		public FilterScope myFilterScope {get; private set;} {myFilterScope = null;}
		public String toSoql() {return this.toSoql(null);}
		public String toSoql(SoqlOptions options) {
			if(options == null) options = SoqlOptions.DEFAULT_OPTIONS;
			String soql = 'FROM ' + this.fromObject;
			switch on myFilterScope {
				when DELEGATED {soql += ' USING SCOPE Delegated';}
				when EVERYTHING {soql += ' USING SCOPE Everything';}
				when MINE {soql += ' USING SCOPE Mine';}
				when MINEANDMYGROUPS {soql += ' USING SCOPE MineAndMyGroups';}
				when MY_TERRITORY {soql += ' USING SCOPE My_Territory';}
				when MY_TEAM_TERRITORY {soql += ' USING SCOPE My_Team_Territory';}
				when TEAM {soql += ' USING SCOPE Team';}
				when else {}
			}
			return soql;
		}
	}
	class OrderBy implements ISoqlable {
		public Field myField {get; set;}
		public SortOrder mySortOrder {get; private set;}
		public NullsOrder myNullsOrder {get; private set;}
		public OrderBy(Field field) {
			this.myField = field;
			this.mySortOrder = SortOrder.ASCENDING;
			this.myNullsOrder = NullsOrder.NULLS_FIRST;
		}
		public OrderBy(String field) {this(new Field(field));}
		public OrderBy ascending() {this.mySortOrder = SortOrder.ASCENDING; return this;}
		public OrderBy descending() {this.mySortOrder = SortOrder.DESCENDING; return this;}
		public OrderBy nullsFirst() {this.myNullsOrder = NullsOrder.NULLS_FIRST; return this;}
		public OrderBy nullsLast() {this.myNullsOrder = NullsOrder.NULLS_LAST; return this;}
		public String toSoql() {return this.toSoql(null);}
		public String toSoql(SoqlOptions options) {
			if(options == null) options = SoqlOptions.DEFAULT_OPTIONS;
			String soql = this.myField.toSoql(options);
			switch on mySortOrder {
				when ASCENDING {soql += ' ASC';}
				when DESCENDING {soql += ' DESC';}
				when else {}
			}
			switch on myNullsOrder {
				when NULLS_FIRST {soql += ' NULLS FIRST';}
				when NULLS_LAST {soql += ' NULLS LAST';}
				when else {}
			}
			return soql;
		}
	}
	class Havingx implements ISoqlable {
		public String toSoql() {return this.toSoql(null);}
		public String toSoql(SoqlOptions options) {
			if(options == null) options = SoqlOptions.DEFAULT_OPTIONS;
			String soql;
			//TODO: Implement this
			return soql;
		}
	}
	class FieldCondition implements ICondition {
		public Boolean notClause {get; private set;}
		public Field myField {get; private set;}
		ConditionOperator operator {get; private set;} {operator = ConditionOperator.EQUALS;}
		public Object value {get; private set;}
		public FieldCondition(Field field) {this.myField = field;}
		public FieldCondition(String field) {this(new Field(field));}
		public FieldCondition(Field field, Object value) {
			this(field);
			this.value = value;
		}
		public FieldCondition(String field, Object value) {this(new Field(field), value);}
		public FieldCondition notx(Boolean isNot) {this.notClause = isNot; return this;}
		public FieldCondition notx() {return notx(true);}
		public FieldCondition equals(Object value) {return setOp(ConditionOperator.EQUALS, value);}
		public FieldCondition notEquals(Object value) {return setOp(ConditionOperator.NOT_EQUALS, value);}
		public FieldCondition lessThan(Object value) {return setOp(ConditionOperator.LESS_THAN, value);}
		public FieldCondition lessThanOrEqualTo(Object value) {return setOp(ConditionOperator.LESS_THAN_OR_EQUAL_TO, value);}
		public FieldCondition greaterThan(Object value) {return setOp(ConditionOperator.GREATER_THAN, value);}
		public FieldCondition greaterThanOrEqualTo(Object value) {return setOp(ConditionOperator.GREATER_THAN_OR_EQUAL_TO, value);}
		public FieldCondition likex(Object value) {return setOp(ConditionOperator.LIKEx, value);}
		public FieldCondition inx(Object value) {return setOp(ConditionOperator.INx, value);}
		public FieldCondition notIn(Object value) {return setOp(ConditionOperator.NOT_IN, value);}
		private FieldCondition setOp(ConditionOperator operator, Object value) {
			this.operator = operator;
			this.value = value;
			return this;
		}
		public String opToString(ConditionOperator operator) {
			switch on operator {
				when EQUALS {return '=';}
				when NOT_EQUALS {return '!=';}
				when LESS_THAN {return '<';}
				when LESS_THAN_OR_EQUAL_TO {return '<=';}
				when GREATER_THAN {return '>';}
				when GREATER_THAN_OR_EQUAL_TO {return '>=';}
				when LIKEx {return 'LIKE';}
				when INx {return 'IN';}
				when NOT_IN {return 'NOT IN';}
				when else {return null;}
			}
		}
		public String toSoql() {return this.toSoql(null);}
		public String toSoql(SoqlOptions options) {
			if(options == null) options = SoqlOptions.DEFAULT_OPTIONS;
			String soql = '';
			if(this.notClause) soql += 'NOT ';
			soql += this.myField + ' ' + opToString(this.operator) + ' ';
			String literalValue = SoqlUtils.toLiteral(value);
			if(this.value != null && this.value instanceOf String && this.operator == ConditionOperator.LIKEx) soql += options.wildcardStringsInLikeOperators(literalValue);
			soql += literalValue;
			return soql;
		}
	}
	abstract class ConditionGroup implements INestableCondition {
		public List<ICondition> conditions {get; private set;}
		ClauseOperator operator {get; set;}
		public ConditionGroup(ClauseOperator operator) {
			this.operator = operator;
			this.conditions = new List<ICondition>();
		}
		public INestableCondition add(ICondition condition) {
			if(condition != null) this.conditions.add(condition);
			return this;
		}
		public String toSoql() {return this.toSoql(null);}
		public String toSoql(SoqlOptions options) {
			if(options == null) options = SoqlOptions.DEFAULT_OPTIONS;
			String soql;
			//TODO: Implement soql string creation
			return soql;
		}
	}
	class AndCondition extends ConditionGroup {
		AndCondition() {super(ClauseOperator.ANDx);}
	}
	class OrCondition extends ConditionGroup {
		OrCondition() {super(ClauseOperator.ORx);}
	}

	//Variables
	private List<Field> selectx = new List<Field>();
	private Fromx fromx = null;
	private List<OrderBy> orderBy = new List<OrderBy>();
	private Integer limitx = null;
	private Integer offsetx = null;
	private Boolean forView = false;
	private Boolean forReference = false;
	private Boolean forUpdate = false;


	//Functions
	public SoqlBuilder selectx(Field field) {this.selectx.add(field); return this;}
	public SoqlBuilder selectx(String field) {selectx(new Field(field)); return this;}
	public String toSoql() {return this.toSoql(null);}
	public String toSoql(SoqlOptions options) {
		if(options == null) options = SoqlOptions.DEFAULT_OPTIONS;
		String soql;
		//TODO: Implement soql string creation
		if(forView) soql += ' FOR VIEW';
		if(forReference) soql += ' FOR REFERENCE';
		if(forUpdate) soql += ' FOR UPDATE';
		return soql;
	}
}