<cfscript>
// the handler can be used as a general logger with abort=0
// the advantage of doing this over passing straight to your
// logger is that it will get the tag context and the extendedinfo

request.prc.debug = 1;

try{
	data = [1,2,3];//we be added to the dump
	glibberty = nohow;// will cause error.
}
catch (any e) {
	local.extendedinfo = {"tagcontext"=e.tagcontext,"data"=data};
	
	local.args = {
		e=e,
		debug=1,
		isAjaxRequest=0,
		logger= application.errorLogger ? : new textLogger( ExpandPath( "/logs/errors" ) ),
		abort=0
	};

	error = new errorHandler(argumentCollection=local.args);
	writeOutput(error.getID());
	
}


writeOutput("<p>Continuing after</p>");



</cfscript>
			