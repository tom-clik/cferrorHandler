<cfscript>
// setting type of custom will show the user the message
try{
	throw(message="Custom message for user",detail="This is a deliberately thrown error to test the system",type="custom");
} 
catch (any e) {
	new cferrorHandler.errorHandler(e=e,isAjaxRequest=0,errorsFolder=expandpath("_output"),debug=0,pageTemplate=fileRead( expandpath("sampleTemplate.html") ) );
}

</cfscript>
			