<cfscript>
// when ajax, return json
request.prc.isAjaxRequest = 1;

writeDump(request.prc);

throw(message="Test error",detail="This is a deliberately thrown error to test the system",type="custom");


</cfscript>
			