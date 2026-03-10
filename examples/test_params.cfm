<cfscript>
// should throw 400 if either of these not present or invalid

/*
If you actually want to track param failures with debug off,
surreound the params with a try catch and throw a custom error.
 */
param name="url.site_id" type="integer";
param name="url.site_code" type="regex" pattern="^[A-Za-z]+$";

writeOutput("Values ok");


</cfscript>
			