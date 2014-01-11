component{
/**
structures to create for configuration

- coldbox
- settings
- conventions
- environments
- ioc
- models
- debugger
- mailSettings
- i18n
- bugTracers
- webservices
- datasources
- layoutSettings
- layouts
- cacheEngine
- interceptorSettings
- interceptors

Available objects in variable scope
- controller
- logBoxConfig
- appMapping (auto calculated by ColdBox)

Required Methods
- configure() : The method ColdBox calls to configure the application.
Optional Methods
- detectEnvironment() : If declared the framework will call it and it must return the name of the environment you are on.
- {environment}() : The name of the environment found and called by the framework.

*/
	
	// Configure ColdBox Application
	function configure(){
	
		// coldbox directives
		coldbox = {
			//Application Setup
			appName 				= "Sigma_Forums",
			
			//Development Settings
			//handlersIndexAutoReload & configAutoReload to false in Production
			debugMode				= false,
			debugPassword			= "",
			reinitPassword			= "",
			handlersIndexAutoReload = false,
			configAutoReload		= false,
			
			//Implicit Events
			defaultEvent			= "General.index",
			requestStartHandler		= "Main.onRequestStart",
			requestEndHandler		= "Main.onRequestEnd",
			applicationStartHandler = "Main.onAppInit",
			applicationEndHandler	= "",
			sessionStartHandler 	= "Main.onSessionStart",
			sessionEndHandler		= "Main.onSessionEnd",
			missingTemplateHandler	= "",
			
			//Extension Points
			UDFLibraryFile 			= "includes/helpers/ApplicationHelper.cfm",
			coldboxExtensionsLocation = "",
			pluginsExternalLocation = "",
			viewsExternalLocation	= "",
			layoutsExternalLocation = "",
			handlersExternalLocation  = "",
			requestContextDecorator = "",
			
			//Error/Exception Handling
			exceptionHandler		= "",
			onInvalidEvent			= "",
			customErrorTemplate		= "",
				
			//Application Aspects
			//handlerCaching & eventCaching to true in Production
			handlerCaching 			= true,
			eventCaching			= true,
			proxyReturnCollection 	= false,
			flashURLPersistScope	= "session",	
		
				PagingMaxRows = 5,
				PagingBandGap = 3
		
		};
	
		
		//LogBox
		/*
		logBox = {
			appenders = {
				coldboxTracer = {class="coldbox.system.logging.appenders.ColdboxTracerAppender"}
					//
					fileLog = {
						class="coldbox.system.logging.appenders.AsyncRollingFileAppender",
					 	properties={
							filePath = "logs",
							fileName = coldbox.appName,
							autoExpand = true,
							fileMaxSize = 2000,
							fileMaxArchives = 3
						}
					}
					
			},
			
			root = {levelMax="DEBUG", appenders="*"}
		};
		*/
		
		
		//Layout Settings
		layoutSettings = {
			defaultLayout = "Layout.default.cfm"
		};
		
		//Register interceptors as an array, we need order
		interceptors = [
			//Autowire
			/*{class="coldbox.system.interceptors.Autowire",properties={entityInjection=true}},*/
			//SES
			{class="coldbox.system.interceptors.SES"}
		];
		
		ioc = {
			framework = "wirebox",
			definitionFile  = "config.WireBox"
		}; 

		wirebox = {
			enabled = true,
			singletonReload = true,
			binder = 'config.WireBox'
		};

		cacheBox = {
			// LogBox config already in coldbox app, not needed
			// logBoxConfig = "coldbox.system.web.config.LogBox", 
		
			// The defaultCache has an implicit name "default" which is a reserved cache name
			// It also has a default provider of cachebox which cannot be changed.
			// All timeouts are in minutes
			defaultCache = {
				objectDefaultTimeout = 120, //two hours default
				objectDefaultLastAccessTimeout = 30, //30 minutes idle time
				useLastAccessTimeouts = true,
				reapFrequency = 2,
				freeMemoryPercentageThreshold = 0,
				evictionPolicy = "LRU",
				evictCount = 1,
				maxObjects = 300,
				objectStore = "ConcurrentStore", //guaranteed objects
				coldboxEnabled = true
			},
		
			// Register all the custom named caches you like here
			caches = {
				// Named cache for all coldbox event and view template caching
				template = {
					provider = "coldbox.system.cache.providers.CacheBoxColdBoxProvider",
					properties = {
						objectDefaultTimeout = 120,
						objectDefaultLastAccessTimeout = 30,
						useLastAccessTimeouts = true,
						reapFrequency = 2,
						freeMemoryPercentageThreshold = 0,
						evictionPolicy = "LRU",
						evictCount = 2,
						maxObjects = 300,
						objectStore = "ConcurrentSoftReferenceStore" //memory sensitive
					}
				}		
			}		
		};

		environments = {
			development = "^sigmaforums.com"
		};

	}

	function development(){
		/*
		coldbox.handlerCaching			= false;
		coldbox.eventCaching			= false;
		coldbox.debugPassword			= "";
		coldbox.reinitPassword			= "";
		coldbox.debugMode				= true;
		coldbox.debugPassword			= "debug";
		coldbox.reinitPassword			= "";
		coldbox.handlersIndexAutoReload = true;
		coldbox.configAutoReload		= true;
		*/
	}
	
}