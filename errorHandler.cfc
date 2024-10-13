/*

# Error handler


## Usage

Used as a proper object.

```cfml
onError(e) {
	new cferrorHandler.errorHandler(e=e);
}
```

### Using a custom logger

A custom logger should implement the Logger interface (loggerInterface.cfc). 

See the supplied text logger (textLogger.cfc) example.


 */ 
component accessors="true" {

	property name="usermessage" type="string";
	property name="message" type="string";
	property name="detail" type="string";
	property name="code" type="string";
	property name="ExtendedInfo";
	property name="type" type="string";
	property name="tagcontext";	
	property name="statuscode" type="integer" default=500 type="string";
	property name="statustext" type="string" default="Error";
	property name="report" type="boolean" default=true;
	property name="id" type="uuid" default="#createUUID()#";

	/**
	 * Initialise error
	 * 
	 * @e       CFML exception
	 * @isAjaxRequest  boolean     Return JSON formatted version
	 * @pageTemplate   Page template for error display. The fields "usermessage","code","statustext","id" should be enclosed in double braces {{}} (mustache style)
	 * @debug        Dump the error instead of displaying error page
	 * @logger       Custom logging component. See loggerInterface and the textLogger example
	 * @message      Error to display to user. Note that if the "type" of the exception is "custom", the exception error message will be shown.
	 * @ExtendedInfo  Manually supply extended info when using as a logger
	 * @abort        Abort and show error page (or dump if debug)
	 */
	public void function init(
		required any      e, 
		         boolean  isAjaxRequest=0,  
		         string pageTemplate="", 
		         boolean debug=0, 
		         any logger,
		         string message = "Sorry, an error has occurred",
		         struct ExtendedInfo,
		         boolean abort=1
		) {

		if ( arguments.keyExists("logger") ) {
			variables.logger = arguments.logger;
		}

		variables.usermessage = arguments.message;
		variables.message =arguments.e.message;
		variables.detail =arguments.e.detail;
		variables.code =arguments.e.errorcode;
		variables.ExtendedInfo = deserializeJSON(arguments.e.ExtendedInfo);
		variables.type =arguments.e.type;
		

		// when using the handler as a logger, sometimes we just want to supply this
		if ( StructKeyExists( arguments, "ExtendedInfo" ) ) {
			variables.ExtendedInfo = arguments.ExtendedInfo;
		}
		// You can catch nested errors by adding error to ExtendedInfo
		else if ( isStruct( variables.ExtendedInfo ) ) {
			getRecursiveInfo( variables.ExtendedInfo );
		}
		
		//supply original tag context in extended info if you have caught and rethrown an error
		if ( isStruct( variables.ExtendedInfo ) AND variables.ExtendedInfo.keyExists( "tagcontext" ) ) {
			variables.tagcontext =  variables.ExtendedInfo.tagcontext;
			StructDelete(variables.ExtendedInfo,"tagcontext");
		}
		else {
			variables.tagcontext =  arguments.e.TagContext;
		}


		
		switch ( type ) {
			case  "badrequest": case "validation":
				variables.statuscode="400";
				variables.statustext="Bad Request";
				variables.report = 0;
				break;
			case  "forbidden":
				variables.statuscode="403";
				variables.statustext="Forbidden";
				variables.report = 0;
				break;
			case  "Unauthorized":
				variables.statuscode="401";
				variables.statustext="Unauthorized";
				variables.report = 0;
				break;

			case "missinginclude": case  "notfound": case  "notfounddetail": case "not found":
				variables.statuscode="410";
				variables.statustext="Page not found";
				variables.report = 0;
				break;
			case "ajaxerror":
				// avoid throwing ajaxerror. better to set isAjaxRequest
				// and throw normal error
				arguments.isAjaxRequest = 1;
				break;
			case  "custom":
				// custom errors show thrown message
				variables.usermessage  = variables.message;
				break;
		}
		// check if we've already start writing page.
		local.IsCommitted = GetPageContext().GetResponse().IsCommitted();

		if (arguments.isAjaxRequest) {

			local.error = {
				"statustext": variables.statustext,
				"statuscode": variables.statuscode,
				"message" : arguments.debug ? variables.message : variables.usermessage
			}

			if ( NOT local.IsCommitted  ) {
				cfheader( statuscode=variables.statuscode, statustext=variables.statustext );
				cfheader( name="errorText", value=variables.statustext );
				content type="application/json; charset=utf-8";
			}

			if (report) {
				local.error["id"] = variables.id;
				logError(getError());
			}
			
			WriteOutput(serializeJSON(local.error));

		}
		else {
			if (arguments.debug) {
				if ( arguments.abort ) {
					writeDump(var=getError(),label="Error");
					abort;
				}
			}
			else {

				if ( variables.report) {
					logError(getError());
				}
				
				if ( arguments.abort ) {
					if ( NOT local.IsCommitted  ) {
						cfheader( statuscode=variables.statuscode, statustext=variables.statustext );
					}
					if ( ! variables.report) {
						abort;
					}					
					
					if (arguments.pageTemplate EQ "") {
						arguments.pageTemplate = "<h1>{{usermessage}}</h1>" &
												"<p>Please contact support quoting ref {{id}}</p>";
					}
					
					for (local.field in ["usermessage","code","statustext","id"]) {
						arguments.pageTemplate = ReplaceNoCase(arguments.pageTemplate,"{{#local.field#}}", variables[local.field],"all");
					}

					writeOutput(arguments.pageTemplate);
					abort;
				}
				
			}
			
		}

	}

	private void function getRecursiveInfo( required struct ExtendedInfo ) {

		if ( arguments.ExtendedInfo.keyExists( "error" ) ) {

			arguments.ExtendedInfo.tagcontext = arguments.ExtendedInfo.error.tagcontext;

			if ( arguments.ExtendedInfo.error.keyExists("ExtendedInfo") ) {
				local.info = deserializeJSON(arguments.ExtendedInfo.error.ExtendedInfo);
				if ( isStruct(local.info) ) {
					getRecursiveInfo(local.info);
					StructAppend(arguments.ExtendedInfo, local.info, true);
				}
			}


			StructDelete( arguments.ExtendedInfo, "error");
		}

	}

	public void function logError(required struct error) {
		if ( variables.keyExists("logger") ) {
			variables.logger.log( arguments.error );
		}
	}

	/** return error as simple struct */
	public struct function getError() {

		return {
			"usermessage"=variables.usermessage,
			"message"=variables.message,
			"detail"=variables.detail,
			"code"=variables.code,
			"ExtendedInfo"=variables.ExtendedInfo,
			"type"=variables.type,
			"statuscode"=variables.statuscode,
			"statustext"=variables.statustext,
			"report"=variables.report,
			"id"=variables.id,
			"tagcontext"=variables.tagcontext
		}
	}
}
