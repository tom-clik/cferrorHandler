<cfscript>
/*

the handler can be used as a general logger with abort=0

here you can create your own error as a struct, or you might be using a caught error in a loop

*/ 

// creating our own error absolutely fine. 
error = {
	"message": "Manual error"
};

local.extendedinfo = {"data"="Sample data"};

logger = new textLogger( ExpandPath( "/logs/errors" ) );

local.args = {
	error = error,
	logger = logger,
	abort = 0,
	extendedinfo = local.extendedinfo
};

for (i in [1,2,3]) {
	error = new errorHandler(argumentCollection=local.args);
	writeOutput(i & ":" & error.getID() & "<br>");
}

writeOutput("<p>Continuing after</p>");

</cfscript>
			