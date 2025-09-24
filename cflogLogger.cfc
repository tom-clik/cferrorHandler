/**
 * Log errors to cflog.
 *
 * See errorHandler
 * 
 */
component implements="loggerInterface" {

	public function init() {
		return this;
	}

	public boolean function log(required struct error) {
		
		cflog( type="error", text=arguments.error.message );
		return true;
		
	}

}