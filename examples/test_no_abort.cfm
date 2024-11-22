<cfscript>
// the handler can be used as a general logger with abort=0
// the advantage of doing this over passing straight to your
// logger is that it will get the tag context and the extendedinfo

try{
	data = [1,2,3];//we be added to the dump
	glibberty = nohow;// will cause error.
}
catch (any e) {
	local.extendedinfo = {"data"=data};
	
	local.args = {
		e=e,
		isAjaxRequest=0,
		logger= application.errorLogger ? : new textLogger( ExpandPath( "/logs/errors" ) ),
		abort=0,
		extendedinfo = local.extendedinfo
	};

	error = new errorHandler(argumentCollection=local.args);
	writeOutput(error.getID());
	
}


writeOutput("<p>Continuing after</p>");



</cfscript>
			