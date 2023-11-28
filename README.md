# cferrorHandler

Simple component for handling errors in in CFML apps

## Background

The error handler is a "proper" component that is instantiated when an error occurs, e.g.

```cfscript
onError(e) {
	new cferrorHandler.errorHandler(e=e,isAjaxRequest=request.isAjaxRequest);
}
```

This is to ensure it can be used in any context and to catch errors on application start up.

To actually log errors, you will need to pass in a logging component. This might well be a singleton pattern component that you have initialised in the application scope, but you will need to ensure your logic copes with it not being defined. See the examples following.

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

When throwing an error from inside a catch block, you can preserve the original tag content by adding it to the extended info. The error handler will replace the tagcontent of the throw error with this info

```cfscript
try {

}
catch (any e) {
	local.extendedinfo = {"tagcontext"=e.tagcontext};
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
	new cferrorHandler.errorHandler(e=e,logger=new cferrorHandler.textLogger(ExpandPath("/logs/_errors") ) );
}
```

## Returning JSON

The `isAjaxRequest` argument will return JSON.

## Sample Code

```cfscript
onError(e) {
	param request.prc = {};

	local.args = {
		e=e,
		debug=request.prc.debug ? : 0,
		isAjaxRequest=request.prc.isAjaxRequest ? : 0,
		pageTemplate=application.errorTemplate ? : "",
		logger= application.errorLogger ? : new textLogger( ExpandPath("/logs/_errors") )
	};

	new errorHandler(argumentCollection=local.args);
}
```
