<cfscript>
// setting type of custom will show the user the error message itself
try{
	throw(message="Custom message for user",detail="This is a deliberately thrown error to test the system",type="custom");
} 
catch (any e) {
	new cferrorHandler.errorHandler(e=e,isAjaxRequest=0,errorsFolder=expandpath("_output"),debug=0  );
}

</cfscript>
			