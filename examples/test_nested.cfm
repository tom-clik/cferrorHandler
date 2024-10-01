<cfscript>
request.prc.debug = 1;

try {
	try{
		data = [1,2,3];//we be added to the dump
		glibberty = nohow;// will cause error.
	}
	catch (any e1) {
		local.extendedinfo = {"tagcontext"=e1.tagcontext,"data"=data};
		throw(
			extendedinfo = SerializeJSON(local.extendedinfo),
			message      = "Error:" & e1.message, 
			detail       = e1.detail,
			errorcode    = "test1"		
		);
	}
}
catch (any e) {
	local.extendedinfo = {"tagcontext"=e.tagcontext,"extendedinfo"=e.extendedinfo};
	throw(
		extendedinfo = SerializeJSON(local.extendedinfo),
		message      = "Error:" & e.message, 
		detail       = e.detail,
		errorcode    = "test2"		
	);
}
</cfscript>
			