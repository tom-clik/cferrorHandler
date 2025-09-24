/**
 * Log errors as CFDUMP to folder
 *
 * See errorHandler
 */
component implements="loggerInterface" {

	/**
	 * @folder   Directory to log errors to
	 */
	public function init(required string folder) {
		variables.folder = arguments.folder;
		return this;
	}

	// CFDUMP the error to a text file.
	public boolean function log(required struct error) {
		
		local.errorCode = 0;
			
		try {
			local.filename = variables.folder & "/" & arguments.error.id & ".html";
			writeDump(var=error,output=local.filename,format="html");
			local.errorCode = 1;
		}
		catch (any e) {
			// Note failure to write to log but continue
			cflog( type="error", text="Unable to write log file:#e.message#" );
		}
		
		return local.errorCode;

	}

}