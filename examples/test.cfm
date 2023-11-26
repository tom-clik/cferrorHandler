<cfscript>
// basic error with template
try{
	throw(message="Test error",detail="This is a deliberately thrown error to test the system");
} 
catch (any e) {
	new cferrorHandler.errorHandler(e=e,isAjaxRequest=0,errorsFolder=expandpath("_output"),debug=0,pageTemplate=fileRead( expandpath("sampleTemplate.html") ) );
}

</cfscript>
			