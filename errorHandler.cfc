/*

# Error handler


## Usage

Used as a proper object.

```cfml
onError(e) {
	new cferrorHandler.errorHandler(e=e,isAjaxRequest=request.isAjaxRequest);
}
```

### Using a custom logger

A custom logger should implement the 


 */ 
component {
	/**
	 * Initialise error
	 * 
	 * @e       CFML exception
	 * @isAjaxRequest  boolean     Return JSON formatted version
	 * @pageTemplate   Page template for error display. The fields "usermessage","code","statustext","id" should be enclosed in double braces {{}} (mustache style)
	 * @debug        Dump the error instead of displaying error page
	 * @logger       Custom logging component. See loggerInterface and the textLogger example
	 * @message      Error to display to user. Note that if the "type" of the exception is "custom", the exception error message will be shown.
	 */
	public void function init(
		required any      e, 
		         boolean  isAjaxRequest=0,  
		         string pageTemplate="", 
		         boolean debug=0, 
		         any logger,
		         string message = "Sorry, an error has occurred"
		) {

		if ( arguments.keyExists("logger") ) {
			variables.logger = arguments.logger;
		}

		var userError = [
			"usermessage"=arguments.message,
			"message"=arguments.e.message,
			"detail"=arguments.e.detail,
			"code"=arguments.e.errorcode,
			"ExtendedInfo"=deserializeJSON(arguments.e.ExtendedInfo),
			"type"=arguments.e.type,
			"statuscode"=500,
			"statustext"="Error",
			"report"=1,
			"id"=createUUID()
		];

		// supply original tag context in extended info if you have caught and rethrown an error
		if ( isStruct( userError.ExtendedInfo ) AND userError.ExtendedInfo.keyExists( "tagcontext" ) ) {
			userError["tagcontext"] =  userError.ExtendedInfo.tagcontext;
			StructDelete(userError.ExtendedInfo,"tagcontext");
		}
		else {
			userError["tagcontext"] =  e.TagContext;
		}
		
		switch ( userError.type ) {
			case  "badrequest": case "validation":
				userError.statuscode="400";
				userError.statustext="Bad Request";
				userError.report = 0;
				break;
			case  "forbidden":
				userError.statuscode="403";
				userError.statustext="Forbidden";
				userError.report = 0;
				break;
			case  "Unauthorized":
				userError.statuscode="401";
				userError.statustext="Unauthorized";
				userError.report = 0;
				break;

			case "missinginclude": case  "notfound": case  "notfounddetail": case "not found":
				userError.statuscode="410";
				userError.statustext="Page not found";
				userError.report = 0;
				break;
			case "ajaxerror":
				// avoid throwing ajaxerror. better to set isAjaxRequest
				// and throw normal error
				arguments.isAjaxRequest = 1;
				break;
			case  "custom":
				// custom errors show thrown message
				userError.usermessage  = userError.message;
				break;
		}
		
		if (arguments.isAjaxRequest) {

			local.error = {
				"statustext": userError.statustext,
				"statuscode": userError.statuscode,
				"message" : arguments.debug ? userError.message : userError.usermessage
			}
			
			// note we don't set a status for reported errors
			// typically we want the client side app to display a friendly
			// message for these.
			if (userError.report) {
				local.error["id"] = userError.id;
				logError(userError);
			}
			else {
				cfheader( statuscode=userError.statuscode, statustext=userError.statustext );
			}
			content type="application/json; charset=utf-8";
			WriteOutput(serializeJSON(local.error));

		}
		else {
			if (arguments.debug) {
				cfheader( statuscode=userError.statuscode, statustext=userError.statustext );
				writeDump(var=userError,label="Error");
			}
			else {
				
				cfheader( statuscode=userError.statuscode, statustext=userError.statustext );
				
				if (! userError.report) {
					abort;
				}

				logError(userError);
				
				if (arguments.pageTemplate EQ "") {
					arguments.pageTemplate = "<h1>{{usermessage}}</h1>" &
											"<p>Please contact support quoting ref {{id}}</p>";
				}
				
				for (local.field in ["usermessage","code","statustext","id"]) {
					arguments.pageTemplate = Replace(arguments.pageTemplate,"{{#local.field#}}", userError[local.field],"all");
				}

				writeOutput(arguments.pageTemplate);
				
			}
			
		}
		
	}

	public void function logError(required struct error) {
		if ( variables.keyExists("logger") ) {
			variables.logger.log( arguments.error );
		}
	}
}