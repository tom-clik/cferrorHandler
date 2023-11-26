<cfscript>
// When debug is set, we dump the error to page (unless in Ajax)
// Note here we show a typical cacth and throw. The tag context
// of the original error will be preserved

try{
	try{
		data = [1,2,3];//we be added to the dump
		glibberty = nohow;// will cause error.
	}
	catch (any e) {
		local.extendedinfo = {"tagcontext"=e.tagcontext,"data"=data};
		throw(
			extendedinfo = SerializeJSON(local.extendedinfo),
			message      = "Error:" & e.message, 
			detail       = e.detail,
			errorcode    = "test1"		
		);
	}

} 
catch (any e) {
	new cferrorHandler.errorHandler(e=e,isAjaxRequest=0,errorsFolder=expandpath("_output"),debug=1,pageTemplate=fileRead( expandpath("sampleTemplate.html") ) );
}

</cfscript>
			