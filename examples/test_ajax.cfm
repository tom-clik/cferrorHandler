<cfscript>
// when ajax, return json
try{
	throw(message="Test error",detail="This is a deliberately thrown error to test the system",type="custom");
} 
catch (any e) {
	new cferrorHandler.errorHandler(e=e,isAjaxRequest=1,errorsFolder=expandpath("_output"),debug=1,pageTemplate=fileRead( expandpath("sampleTemplate.html") ) );
}

</cfscript>
			