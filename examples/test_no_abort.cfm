<cfscript>
/*

the handler can be used as a general logger with abort=0

here you can create your own error as a struct, or you might be using a caught error in a loop

*/ 

// creating our own error absolutely fine. 
e = {
	"message": "Manual error"
};

local.extendedinfo = {"data"="Sample data"};

logger = new textLogger( ExpandPath( "/logs/errors" ) );

local.args = {
	error=e,
	logger= logger,
	abort=0,
	extendedinfo = local.extendedinfo
};

error = new errorHandler(argumentCollection=local.args);
writeOutput(error.getID());

writeOutput("<p>Continuing after</p>");



</cfscript>
			