component {

	this.name = "errorHandlerTest";
	
	// Don't do this in production!!
	// /logs/_errors should be a mapping outside webroot
	this.mappings["/logs/errors"]=ExpandPath("_output");
	// just for usage in this example.
	// better to put all your library components in a single location.
	// And use dot paths for intialisation e.g. new cferrorHandler.errorHandler
	this.componentpaths["errors"]=ExpandPath("../../cferrorHandler");

	function onApplicationStart() {
		
		// use the standard text logger -- just to illustrate
		// instantiated object pattern. You would replace this 
		// with something more sophisticated. 
		
		application.errorLogger = new textLogger( folder=ExpandPath( "/logs/errors" ) );
		application.errorTemplate = FileRead( ExpandPath( "./sampleTemplate.html" ) );
	}

	function onRequestStart(string targetPage) {
		
		// just while we're playing around...
		onApplicationStart()

		request.prc = {debug=0,isAjaxRequest=0};
	}

	function onError(e) {

		param request.prc = {};

		local.args = {
			e=e,
			debug=request.prc.debug ? : 0,
			isAjaxRequest=request.prc.isAjaxRequest ? : 0,
			pageTemplate=application.errorTemplate ? : "",
			logger= application.errorLogger ? : new textLogger( ExpandPath( "/logs/errors" ) )
		};

		new errorHandler(argumentCollection=local.args);
	}


}