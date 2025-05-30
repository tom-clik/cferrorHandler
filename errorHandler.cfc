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

	property name="usermessage" type="string"; // message shown to users in friendly error page
	property name="message" type="string"; // actual error message as thrown
	property name="detail" type="string"; // detail from error
	property name="code" type="string"; // error code if supplied in throw
	property name="ExtendedInfo"; // See notes, used extensively for debug information, usually as JSON encoded struct
	property name="type" type="string"; // Error type. badrequest|validation|forbidden|Unauthorized|missinginclude|notfound|notfounddetail|not found|custom note some types will not trigger the logger (if used)
	property name="tagcontext" type="array"; // tag context array
	property name="statuscode" type="integer" default=500; // numeric http code. Will be set as a header
	property name="statustext" type="string" default="Error"; // http statuc. Will be set as a header
	property name="report" type="boolean" default=true; // Use logger component (qv) to log error.
	property name="id" type="uuid" default="#createUUID()#"; // Unique ID for logging. Can be supplied to users in error page to aid support.
	property name="debugsql" type="string" default=""; // runnable SQL if params and sql are provided in extended info

	/**
	 * Initialise error
	 * 
	 * @error          CFML exception
	 * @ajax           Return JSON formatted version
	 * @pageTemplate   Page template for error display. The fields "usermessage","code","statustext","id" should be enclosed in double braces {{}} (mustache style)
	 * @debug          Dump the error instead of displaying error page
	 * @logger         Custom logging component. See loggerInterface and the textLogger example
	 * @message        Error to display to user. Note that if the "type" of the exception is "custom", the exception error message will be shown.
	 * @ExtendedInfo   DEPRECATED Manually supply extended info when using as a logger.
	 * @abort          Abort and show error page (or dump if debug)
	 */
	public void function init(
		         any      error = {}, 
		         boolean  ajax=0,  
		         string   pageTemplate="", 
		         boolean  debug=0, 
		         any      logger,
		         string   message = "Sorry, an error has occurred",
		         struct   ExtendedInfo,
		         boolean  abort=1
		) {

		if ( arguments.keyExists("logger") ) {
			variables.logger = arguments.logger;
		}

		// legacy 'e' alias for error
		if ( arguments.keyExists("e") ) {
			StructAppend(arguments.error, arguments.e, true);
		}

		// it's fine to supply your own struct as an error, here we check the required fields
		StructAppend(arguments.error, {"message"="Message not specified","detail"="","errorcode"="","ExtendedInfo"="","type"="error","TagContext"=[]}, false);

		variables.usermessage = arguments.message;
		variables.message =arguments.error.message;
		variables.detail =arguments.error.detail;
		variables.code =arguments.error.errorcode;
		variables.ExtendedInfo = deserializeJSON(arguments.error.ExtendedInfo);
		variables.type =arguments.error.type;
		

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
			variables.tagcontext =  arguments.error.TagContext;
		}

		if ( isStruct( variables.ExtendedInfo ) 
			AND variables.ExtendedInfo.keyExists( "sql" ) 
			AND variables.ExtendedInfo.keyExists( "params" )
			) {

			variables.debugsql = debugSQLQuery(sql=variables.ExtendedInfo.sql,params=variables.ExtendedInfo.params);

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
				// avoid throwing ajaxerror. better to set ajax
				// and throw normal error
				arguments.ajax = 1;
				break;
			case  "custom":
				// custom errors show thrown message
				variables.usermessage  = variables.message;
				break;
			

		}
		// check if we've already start writing page.
		local.IsCommitted = GetPageContext().GetResponse().IsCommitted();

		if (arguments.ajax) {

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

		return [
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
			"tagcontext"=variables.tagcontext,
			"debugsql"=variables.debugsql
		]
	}

	/**
	 * Generate a runnable SQL script to add to error dump
	 * 
	 * @SQL    sql query
	 * @params struct of query parameters
	 */
	private string function debugSQLQuery(required string SQL, required struct params) localmode=true {
		
		ret = "";

		for (param in arguments.params) {
			paramvals = arguments.params[param];
			type = debugSQLType( paramvals );
			list = ( paramvals.list ? : false );
			val = debugSQLValue(val=paramvals.value, sqltype=type, list=list);
			// no simple way to handle list values so we just inline them
			if (! list) {
				val_str = ( paramvals.null ? : false ) ? "" : " = " & val;
				ret &= "DECLARE @#param# #type# #val_str# ;" & newLine();
			}
			else {
				arguments.SQL = Replace(arguments.SQL,":#param#",val,"all");
			}
		}

		ret &= Replace(arguments.SQL,":","@","all") & newLine();

		return ret;

	} 

	private string function debugSQLType(required struct param) localmode=true {
		
		type = ( arguments.param.type ? : ( arguments.param.cfsqltype ? : "text")  );
		switch (type) {
			case "integer": case "cf_sql_integer": case "int": case "cf_sql_int": 
				return "INT";
			case "boolean": case "bit": case "cf_sql_bit": case "cf_sql_boolean": 
				return "BIT";
			case "cf_sql_date": case "date":  
				return "DATE";
			case "cf_sql_datetime":  case "datetime":
				return "DATETIME";
			default:
				return "VARCHAR(max)";
		}
	}

	private string function debugSQLValue(required any val, required string sqltype, boolean list=false) localmode=true {
		if ( isArray(arguments.val) ) {
			arguments.val = arguments.val.toList();
		}

		switch (arguments.sqltype) {
			case "INT":
				return arguments.val;	
			case "BIT":
				return arguments.val ? "1" : "0" ;
			case "DATE":
				try {
					dateVal = CreateODBCDate(arguments.val);
				}
				catch (any e) {
					dateVal = arguments.val;
				}
				return dateVal;
			case "DATETIME":
				try {
					dateVal = CreateODBCDateTime(arguments.val);
				}
				catch (any e) {
					dateVal = arguments.val;
				}
				return dateVal;
			default:
				if (arguments.list) {
					return listQualify(arguments.val, "'") ;
				}
				else {
					return "'#arguments.val#'";
				}
				
		}

	}
	

}
