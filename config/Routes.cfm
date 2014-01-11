<cfscript>
	// General Properties
	setEnabled(true);
	setUniqueURLS(false);
	
	// Base URL
	if( len(getSetting('AppMapping') ) lte 1){
		setBaseURL("http://#cgi.HTTP_HOST#/");
	}
	else{
		setBaseURL("http://#cgi.HTTP_HOST#/#getSetting('AppMapping')#/index.cfm");
	}
	/*
	addRoute(pattern="/forums/:action?",handler="forums.general",action="index");
	
	addRoute(pattern="/admin/:action?",handler="admin.general",action="index");
	*/

	addRoute(pattern=":handler/:action?");

</cfscript>