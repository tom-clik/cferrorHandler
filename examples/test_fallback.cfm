<cfscript>
// This will undefine the application properties
// Use it to check your fallback code

structDelete(application, "errorTemplate");
structDelete(application, "errorLogger");

throw(
	message      = "Fallback error", 
	errorcode    = "test_fallback"		
);

</cfscript>
			