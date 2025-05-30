<cfscript>
/*
Error handler works well with queries run using queryExecute

When keys "sql" and "params" are added to the extendedinfo, an extra field debugsql is added to the error dump.

This should be runnable in a query editor.

*/

request.prc.debug = 1;

sql = "
	SELECT *
	FROM   articles
	WHERE  live = :live
	AND    pubdate > :pubdate
";
params = {
	"live":{value=true, cfsqltype="cf_sql_boolean"},
	"pubdate":{value=DateAdd("d", -1,  now()) , type="cf_sql_date"}
};

try{
	vals = queryExecute( sql, params );
}
catch (any e) {
	local.extendedinfo = {"error"=e,"sql"=sql,"params"=params};
	throw(
		extendedinfo = SerializeJSON(local.extendedinfo),
		message      = "SQL Error:" & e.message, 
		detail       = e.detail	
	);
}

</cfscript>
			