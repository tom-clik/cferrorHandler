# cferrorHandler

Simple component for handling errors in in CFML apps

## Background

The error handler is a "proper" component that is instantiated when an error occurs, e.g.

```cfscript
onError(e) {
	new cferrorHandler.errorHandler(error=e);
}
```

This is to ensure it can be used in any context and to catch errors on application start up.

To actually log errors, you will need to pass in a logging component. 

```cfscript
onError(e) {
	new cferrorHandler.errorHandler(error=e, logger = application.errorLogger ? : new cferrorHandler.cflogLogger() );
}
```

This might well be a singleton pattern component that you have initialised in the application scope, but you will need to ensure your logic copes with it not being defined. In the above example, a fallback logger to write to the cflog is used.

## Extended Info

The component allows the ExtendedInfo for an error to contain debug information. When throwing an error, serialise the data you want to debug and the errorHandler will deserialize it.

```cfscript
local.extendedinfo = {"data"=data};
throw(
	extendedinfo = SerializeJSON(local.extendedinfo),
	message      = "Unable to do something:" & e.message, 
	detail       = e.detail,
	errorcode    = "test1"		
);
```

## Preserving the original tag context

When throwing an error from inside a catch block, you can preserve the original tag context by adding the error to the extended info. The error handler will replace the tagcontext of the thrown error with this info. It will also append any other data so the eventual error contains all extendedinfo from nested errors.

```cfscript
try {

}
catch (any e) {
	local.extendedinfo = {"error"=e};
	throw(
		extendedinfo = SerializeJSON(local.extendedinfo),
		message      = "Unable to do something:" & e.message, 
		detail       = e.detail,
		errorcode    = "test2"		
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

## Usage

| Argument  | Type      | Description
|-----------|-----------|-------------------------
| 