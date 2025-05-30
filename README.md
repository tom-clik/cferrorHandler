# cferrorHandler

Simple component for handling errors in in CFML apps

## Background

The error handler is a component that is instantiated when an error occurs, e.g.

```cfscript
onError(e) {
	new cferrorHandler.errorHandler(error=e);
}
```

It normally terminates after doing its thing (see following), but it can be set to return the error object and continue.

To log errors, you will need to pass in a logging component. 

```cfscript
onError(e) {
	new cferrorHandler.errorHandler(error=e, logger = application.errorLogger ? : new cferrorHandler.cflogLogger() );
}
```

This might well be a singleton pattern component that you have initialised in the application scope, but you will need to ensure your logic copes with it not being defined. In the above example, a fallback logger to write to the cflog is used.

## Extended Info

The component allows the `ExtendedInfo` for an error to contain debug information. When throwing an error, serialise the data you want to debug and the errorHandler will deserialize it.

```cfscript
local.extendedinfo = {"data"=data};
throw(
	extendedinfo = SerializeJSON(local.extendedinfo),
	message      = "Unable to do something:" & e.message, 
	detail       = e.detail	
);
```

## Preserving the original tag context

When throwing an error from inside a catch block, you can preserve the original error and tag context by adding the error to the extended info. The error handler will replace the tagcontext of the thrown error with this info. It will also append any other data so the eventual error contains all extended info from nested catch blocks.

```cfscript
try {

}
catch (any e) {
	local.extendedinfo = {"error"=e};
	throw(
		extendedinfo = SerializeJSON(local.extendedinfo),
		message      = "Unable to do something:" & e.message, 
		detail       = e.detail	
	);
}
```

## Logging Errors

To log errors, you need to supply a component that implements the loggerInterface. See for example the textLogger.

```cfscript
onError(e) {
	new cferrorHandler.errorHandler(error=e,logger=new cferrorHandler.textLogger(ExpandPath("/logs/_errors") ) );
}
```

## Returning JSON

The `ajax` argument will return JSON. You can set a request variable in your APIs to ensure this is set to true, see sample code following.

## Sample Code

```cfscript
onError(e) {
	param request.prc = {};

	local.args = {
		error=arguments.e,
		debug=request.prc.debug ? : 0,
		ajax=request.prc.isAjaxRequest ? : 0,
		pageTemplate=application.errorTemplate ? : "",
		logger= application.errorLogger ? : new textLogger( ExpandPath("/logs/_errors") )
	};

	new errorHandler(argumentCollection=local.args);
}
```

## Logging without aborting

Sometimes you want to log a caught error but continue operations. This can be done by supplying the `abort=false` argument. See the `test_no_abort` sample script for more information.

## Ignoring "hack" type errors

A "type" can be supplied to indicate the error should not be logged. This avoids your logs being flooded with invalid requests from hacker traffic. The types of **"badrequest"**,**"validation"**, **"forbidden"**, and **"unauthorized"** will return the relevant `4xx` status code and not call the logger.

Page not found errors will return a 410 and not log. The simplest way to change this is to use an `onMissingTemplate` method in your application. See the commented out example in `application.cfc`

## Custom errors

The default user message is "Sorry an error has occurred". This can be changed in two ways: either by supplying a different value on initiation, or by setting the error type to `custom`, which will show the thrown error message to the user.

### Global change

```cfscript
onError(e) {
	new cferrorHandler.errorHandler(error=e, message="Lo sentimos, se ha producido un error.");
}
```

### Custom type

```
throw(message="Custom message for user",detail="This won't be shown",type="custom");
```

## SQL Errors

Error handler works well with queries run using `queryExecute`. When keys `sql` and `params` are added to the extendedinfo, an extra field `debugsql` is added to the error dump. This should be runnable in a query editor. See the sample `test_sql` for details.

E.g.

```cfml
try {
	vals = queryExecute( sql, params );
}
catch (any e) {

	local.extendedinfo = {"error"=e,"sql"=sql,"params"=params};
	throw(
		extendedinfo = SerializeJSON(local.extendedinfo),
		message      = "Error:" & e.message, 
		detail       = e.detail	
	);
```

## Error Templates

An html template to display to the end user can be specified in the argument `pageTemplate`. It uses mustache like syntax ( i.e. `{{fieldname}}` ), with the following fields:

usermessage
: Public error message
code
: error code from a cfthrow
statustext
: http status text
id
: error UUID - can be made public and used to diagnose the error from your logs
