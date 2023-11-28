<cfscript>
// some types are set not to log.
// You can explicity use these not to bother logging bad requests etc
throw(message="You won't see any of this",detail="This is a deliberately thrown error to test the system",type="badrequest");


</cfscript>
			