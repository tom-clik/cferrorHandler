/*

# Error handler


## Usage

Used as a proper object.

```cfml
onError(e) {
	new errors.ErrorHandler(e=e,isAjaxRequest=request.isAjaxRequest,errorsFolder=this.errorsFolder);
}
```


 */ 
component {

	public void function init(e, boolean isAjaxRequest=0, errorsFolder="", pageTemplate="", debug=0) {
		
		this.errorsFolder = arguments.errorsFolder;
		var userError = [
			"usermessage"="Sorry, an error has occurred",
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

			case "missinginclude": case  "notfound": case  "notfounddetail":case "not found":
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
				// custom error messages show thrown message
				userError.usermessage  = userError.message;
				break;
		}
		
		if (arguments.isAjaxRequest) {

			local.error = {
				"statustext": userError.statustext,
				"statuscode": userError.statuscode,
				"message" : arguments.debug ? userError.message : userError.usermessage
			}
			
			if (userError.report) {
				local.error["id"] = userError.id;
				logError(userError);
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
				
				local.errortext = "<h1>Error</h1>";
				local.errortext &= "<p>" & userError.usermessage & "</p>";
				local.errortext &= "<p>Please contact support quoting ref #userError.id#</p>";
				
				if (arguments.pageTemplate EQ "") {
					arguments.pageTemplate = "<h1>Error</h1><p>{{usermessage}}</p>" &
											"<p>Please contact support quoting ref {{id}}</p>";
				}
				
				for (local.field in ["usermessage","code","statustext","id"]) {
					arguments.pageTemplate = Replace(arguments.pageTemplate,"{{#local.field#}}", userError[local.field],"all");
				}

				writeOutput(arguments.pageTemplate);
				
			}
			
		}
		
	}

	public boolean function logError(required struct error) {
		local.errorCode = 0;
		if (this.errorsFolder != "")  {
			try {
				local.filename = this.errorsFolder & "/" & arguments.error.id & ".html";
				writeDump(var=error,output=local.filename,format="html");
				local.errorCode = 1;
			}
			catch (any e) {
				// ignore failure to write to log
			}
		}

		return local.errorCode;

	}
}