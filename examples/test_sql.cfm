<cfscript>
/*
Error handler works well with queries run using queryExecute

When keys "sql" and "params" are added to the extendedinfo, an extra field debugsql is added to the error dump.

This should be runnable in a query editor.

In this test script we extract the script to display it. In a normal thrown error, it would be a key of the dumped error.

*/

request.prc.debug = 1;

/** This query isn't meant to run! It should just throw error */
sql = "
	SELECT *
	FROM   articles
	WHERE  live = :live
	AND    pubdate > :pubdate
	AND    pubdate < :pubdate2
	AND    headline like :headline
	AND    articles_types_id in ( :types ) 
	AND    articles_types_id not in ( :types2 ) 
";
// method should cope with using `cfsqltype` or `type` for the attribute name and the optional `cf_sql_` prefix on the value
params = {
	"live":{value=true, cfsqltype="cf_sql_boolean"},
	"pubdate":{value=DateAdd("d", -7,  now()) , type="datetime"},
	"pubdate2":{value=DateAdd("d", -3,  now()) , type="date"},
	"types":{value="1,2,3",type="integer",list=true},
	"types2":{value=[4,5],cfsqltype="int",list=true},
	"headline": {value='%man bites dog%'}
};

try{
	vals = queryExecute( sql, params );
}
catch (any e) {

	local.extendedinfo = {"error"=e,"sql"=sql,"params"=params};

	/*
	you could just throw as per normal here, but in this script we want to demo the debug SQL
	so we'll create a handler manually. To throw, use
	
	throw(
		extendedinfo = SerializeJSON(local.extendedinfo),
		message      = "Error:" & e.message, 
		detail       = e.detail	
	);
	*/

	local.args = {
		error=e,
		abort=0,
		extendedinfo = local.extendedinfo
	};

	// again, we want to demo the debug sql field so we don't abort and return the error
	error = new errorHandler(argumentCollection=local.args).getError();
	writeOutput("<pre>#htmlCodeFormat(error.debugsql)#</pre>");
	
}

</cfscript>
			