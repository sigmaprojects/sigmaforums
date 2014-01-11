component {
	
	//property name="installService" inject="model:installService@Solitary";

	// Module Properties
	this.title 				= "Sigma Forums";
	this.author 			= "Don Q";
	this.webURL 			= "http://www.sigmaprojects.org";
	this.description 		= "A Forums Module";
	this.version			= "0.2";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	// Module Entry Point
	this.entryPoint			= "forums";
	
	function configure(){
		
		// parent settings
		parentSettings = {
		
		};
	
		// module settings - stored in modules.name.settings
		settings = {
			// emails are sent from
			sendEmailFrom = "web@sigmaprojects.org",
			repliesPerPage = 15,
			topicsPerPage = 15
		};
		
		// Layout Settings
		layoutSettings = {
			defaultLayout = "layout.default.cfm"
		};
		
		// datasources
		datasources = {
			
		};
		
		// web services
		webservices = {
		
		};
		
		
		// SES Routes
		routes = [
			{pattern="/", handler="forums",action="index"},
			{pattern="/areas/", handler="forums",action="index"},
			{pattern="/sections/:areaid-numeric/:areaTitle?", handler="forums",action="sections"},
			{pattern="/topics/:sectionid-numeric/:sectionTitle?", handler="forums",action="topics"},
			{pattern="/replies/:topicid-numeric/:topicTitle?", handler="forums",action="replies"},
			
			{pattern="/editTopic/:sectionid-numeric?", handler="forums",action="editTopic"},
			{pattern="/saveTopic/", handler="forums",action="saveTopic"},
			{pattern="/editReply/:topicid/", handler="forums",action="editReply"},
			{pattern="/saveReply/", handler="forums",action="saveReply"},
			{pattern="/profile/:username/:userid-numeric?", handler="forums",action="viewProfile"},
			{pattern="/users/editProfile/saveProfile", handler="users.editProfile",action="saveProfile"},
			{pattern="/users/editProfile/", handler="users.editProfile",action="editProfile"},
			{pattern="/users/editSignature/", handler="users.editProfile",action="editSignature"},
			{pattern="/users/editNotifications/", handler="users.editProfile",action="editNotifications"},
			{pattern="/users/editRemoveSubscription/", handler="users.editProfile",action="editRemoveSubscription"},
			
			{pattern="/plugins/rating/rate/:replyid-numeric/:rateindex?", handler="plugins.Rating",action="rate"}
		];
		
		/*
		// Custom Declared Points
		interceptorSettings = {
			customInterceptionPoints = ""
		};
		*/
		interceptorSettings = {
			throwOnInvalidStates = false,
			customInterceptionPoints = "htmlTitle"
		};
		
		// Custom Declared Interceptors			
		interceptors = [
			{class="coldbox.system.interceptors.Autowire",properties={entityInjection=true}},
			{class="sigmaforums.interceptors.htmlTitle",properties={}} //this will prob be removed later, just learning how to make an interceptor
		];


		// wirebox mappings

		binder.map("TopicStatusService@SigmaForums")
			.to("#moduleMapping#.model.forums.Topic.TopicStatusService")
			.asSingleton();

		
		binder.map("User_InformationService@SigmaForums")
			.to("#moduleMapping#.model.forums.User_InformationService")
			.asSingleton();	
		
		binder.map("AreaService@SigmaForums")
			.to("#moduleMapping#.model.forums.Area.AreaService")
			.asSingleton();
		
		binder.map("SectionService@SigmaForums")
			.to("#moduleMapping#.model.forums.Section.SectionService")
			.asSingleton();
		
		binder.map("TopicService@SigmaForums")
			.to("#moduleMapping#.model.forums.Topic.TopicService")
			.asSingleton();

		binder.map("ReplyService@SigmaForums")
			.to("#moduleMapping#.model.forums.Reply.ReplyService")
			.asSingleton();

		binder.map("SubscriptionService@SigmaForums")
			.to("#moduleMapping#.model.forums.Subscription.SubscriptionService")
			.asSingleton();


		binder.map("RatingService@SigmaForums")
			.to("#moduleMapping#.model.plugins.RatingService")
			.asSingleton();



		/*
		*/
		/*
		binder.map("AreaService@SigmaForums")
			.toDSL("entityService:Area")
			.asSingleton(); 
		binder.map("SectionService@SigmaForums")
			.toDSL("entityService:Section")
			.asSingleton(); 
		binder.map("TopicService@SigmaForums")
			.toDSL("entityService:Topic")
			.asSingleton();
		binder.map("ReplyService@SigmaForums")
			.toDSL("entityService:Reply")
			.asSingleton(); 
		binder.map("User_InformationService@SigmaForums")
			.toDSL("entityService:User_Information")
			.asSingleton(); 
		*/
		
		/*

		*/
		
		
		/*
		binder.map("SecurityService@Solitary")
			.to("#moduleMapping#.model.security.SecurityService")
			.asSingleton();
			
		binder.map("UserService@Solitary")
			.to("#moduleMapping#.model.users.UserService")
			.asSingleton();	
		
		binder.map("RoleService@Solitary")
			.to("#moduleMapping#.model.roles.RoleService")
			.asSingleton();
			
		binder.map("InstallService@Solitary")
			.to("#moduleMapping#.model.install.Install")
			.asSingleton();
			*/
	}
	
	/**
	 * Fired when the module is registered and activated.
	 */
	public void function onLoad(){
		/*
		var setupPath = getDirectoryFromPath(getCurrentTemplatePath()) & "config\setup.xml";
		var installService = binder.getInjector().getInstance("InstallService@Solitary");
		*/
		
		// if a file named setup.xml exists in the config folder lets install some default data
		/*	
		if( fileExists(setupPath) ){
			installService.setConfigPath(setupPath);
			installService.setup();
		}
		*/
	}
	
	/**
	 * Fired when the module is unregistered and unloaded
	 */
	public void function onUnload(){
		
	}
	
}