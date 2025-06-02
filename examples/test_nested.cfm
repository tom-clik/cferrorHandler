<!---

# Test nested errors

By always including the error in the extended info, we can ensure the tag context comes be from the first error. 

ExtendedInfo should combine all the data from the different errors

See also the logic for error message and detail.

Detail is always the detail of the caught, and hence the detail of the root error.

Message can be the same, but often it's useful as here to prepend a message to create a hierarchy.

--->
<cfscript>
request.prc.debug = 1;

try{
	
	try {
		try{
			data = [1,2,3];//we be added to the dump
			glibberty = nohow;// will cause error.
		}
		catch (any e1) {
			local.extendedinfo = {"error"=e1, "data"=data};
			throw(
				extendedinfo = SerializeJSON(local.extendedinfo),
				message      = "First Error: " & e1.message, 
				detail       = e1.detail,
				errorcode    = "test1"		
			);
		}
	}
	catch (any e2) {
		local.extendedinfo = {"error"=e2,"name"="second error"};
		throw(
			extendedinfo = SerializeJSON(local.extendedinfo),
			message      = "Second Error: " & e2.message, 
			detail       = e2.detail,
			errorcode    = "test2"		
		);
	}
}
catch (any e3) {
	local.extendedinfo = {"error"=e3,"name3"="third error"};
	throw(
		extendedinfo = SerializeJSON(local.extendedinfo),
		message      = "Third Error: " & e3.message, 
		detail       = e3.detail,
		errorcode    = "test3"		
	);
}
</cfscript>
			