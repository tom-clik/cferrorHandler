component implements="loggerInterface" {

	public function init(required string folder) {
		variables.folder = arguments.folder;
	}

	public boolean function log(required struct error) {
		local.errorCode = 0;
			
		try {
			local.filename = variables.folder & "/" & arguments.error.id & ".html";
			writeDump(var=error,output=local.filename,format="html");
			local.errorCode = 1;
		}
		catch (any e) {
			// ignore failure to write to log
		}
		

		return local.errorCode;

	}

}