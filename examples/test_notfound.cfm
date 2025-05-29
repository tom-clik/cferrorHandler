<!---

Should return a 410 without logging. 

The simplest way to change this is to use an onMissingTemplate method in your application. See the commented out
example in application.cfc

--->
<cfscript>
location(url="Missing_page.cfm",addtoken=false);
</cfscript>
			