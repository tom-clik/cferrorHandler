<!---

Basic example will show error using sampleTemplate.html and log the error to
_output (see application.cfc where we define the default logger to be an instance of textLogger)

--->

<cfscript>


throw(message="Test error",detail="This is a deliberately thrown error to test the system");


</cfscript>
			