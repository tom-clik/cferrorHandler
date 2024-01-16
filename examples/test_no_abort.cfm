<cfscript>
// When debug is set, we dump the error to page (unless in Ajax)
// Note here we show a typical catch and throw. The tag context
// of the original error will be preserved
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
			