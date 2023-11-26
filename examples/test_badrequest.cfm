<cfscript>
// some types are set not to log.
// You can explicity use these not to bother logging bad requests etc
try{
	throw(message="You won't see any of this",detail="This is a deliberately thrown error to test the system",type="badrequest");
} 
catch (any e) {
	new cferrorHandler.errorHandler(e=e,isAjaxRequest=0,errorsFolder=expandpath("_output"),debug=0,pageTemplate=fileRead( expandpath("sampleTemplate.html") ) );
}

</cfscript>
			