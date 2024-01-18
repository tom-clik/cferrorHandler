<cfscript>

writeOutput("already written");
cfflush();

throw(message="This should not set status code",type="custom", detail="The handler should detect that the page has been flushed and not try to set a header");

</cfscript>
			