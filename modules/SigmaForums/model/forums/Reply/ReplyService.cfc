component extends="coldbox.system.orm.hibernate.VirtualEntityService" singleton {
	

	public ReplyService function init(
		topicStatusService="" inject="model:topicStatusService@SigmaForums",
		topicService="" inject="model:topicService@SigmaForums",
		subscriptionService="" inject="model:subscriptionService@SigmaForums",
		sessionStorage="" inject="coldbox:plugin:SessionStorage",
		user_InformationService="" inject="model:user_InformationService@SigmaForums"
		){
		super.init(entityName="Reply",queryCacheRegion='query.forums.reply.query',useQueryCaching=true,eventHandling=true);//does the caching really work?
		variables.topicStatusService = arguments.topicStatusService;
		variables.topicService = arguments.topicService;
		variables.subscriptionService = arguments.subscriptionService;
		variables.sessionStorage = arguments.sessionStorage;
		variables.user_InformationService = arguments.user_InformationService;
		return this;
	}


	public void function save(required Reply Reply) {
		var Topic = arguments.Reply.getTopic();
		
		//all this is just making sure its a 'new' reply, and not an edit
		if( IsNull(Arguments.Reply.getReplyID() or !Len(Arguments.Reply.getReplyID()))) {
		
			variables.topicStatusService.resetStoredTopicStatus( Topic.getTopicID() );		
			Topic.setLastPost( Now() );
			variables.topicService.save(Topic);
			
			var userid = sessionStorage.getVar('user',{userid=0}).userid;
			var user_Information = user_InformationService.get( userid );
			if( user_Information.getAuto_Subscribe() ) {
				subscriptionService.checkCreate( Topic.getTopicID(), userid );
			}
			subscriptionService.notify( arguments.reply );
		}
		
		super.Save(arguments.Reply);
		
	}
}