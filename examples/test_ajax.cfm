<cfscript>
// when ajax, return json. Use your chosen mechanism for indicating this, see the onError method
// I prefer just to use a variable like this
request.prc.isAjaxRequest = 1;
request.prc.debug = 1; // has no effect in Ajax context. Dumping not useful.

throw(message="Test error",detail="This is a deliberately thrown error to test the system",type="custom");

</cfscript>
			