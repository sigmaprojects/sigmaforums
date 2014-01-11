component extends="coldbox.system.orm.hibernate.VirtualEntityService" singleton {


	public SubscriptionService function init(
		topicService=""		inject="model:topicService@SigmaForums",
		sessionStorage=""	inject="coldbox:plugin:SessionStorage",
		mailService=""		inject="coldbox:plugin:MailService",
		renderer=""			inject="coldbox:plugin:Renderer",
		configBean=""		inject="coldbox:configBean"
	){
		super.init(entityName="Subscription");
		variables.topicService =	arguments.topicService;
		variables.sessionStorage =	arguments.sessionStorage;
		variables.mailService =		arguments.mailService;
		variables.renderer =		arguments.renderer;
		variables.configBean =		arguments.configBean;
		return this;
	}
	
	
	// at this time, ColdBox isnt handling composite keys for 'exists' very well, so.. lets breakout
	public void function checkCreate(required string topicid, required string userid) {
		var CompositeKey = {
			topicid	= Trim(Arguments.topicid),
			userid	= Trim(Arguments.userid)
		};
		
		if( isNull(EntityLoadByPK('Subscription',CompositeKey)) ) {
			var Subscription = super.New('Subscription', Arguments);
			super.save( Subscription );
		}
	}
	
	public void function resetSentTrigger(required string topicid, required string userid) {
		if(Len(arguments.topicid) && Len(arguments.userid)) {
			var subscription = super.get(Arguments);
			if(!IsNull(subscription)) {
				subscription.setSent( false );
				super.save(subscription);
			}
		}
	}


	public void function notify(required reply) {
		var criteria = {
			topicid=arguments.reply.getTopic().getTopicID(),
			sent=false
		};
		var subscriptions = super.list(criteria=criteria,asQuery=false);
		var user = sessionStorage.getVar('user',{});
		var i = 1;
		for(i=1;i<=ArrayLen(subscriptions);i++) {
			if(StructKeyExists(User,'UserID') && User.UserID != Arguments.Reply.getUser_ID()) {
				send(subscriptions[i],arguments.reply);
				subscriptions[i].setSent(true);
				super.save(subscriptions[i]);
			}
		}
		
	}
	
	
	//can't really test this, CB's mailservice is barfing on something, 'Exception reading response'.
	//so it gets 'sent', but is trapped in undeliv mail.  no clue why, good luck!
	public void function send(required subscription, required reply) {
		var settings = configBean.getKey("modules").SigmaForums.settings;
		var baseURL = len(configBean.getKey('sesBaseURL')) ? configBean.getKey('sesBaseURL') : configBean.getKey('htmlBaseURL');
		var topic = arguments.reply.getTopic();
		var user = arguments.reply.getUser();
		var emailView = 'notification/subscriptionNotification';
		
		
		// Create a new mail object
		local.email = MailService.newMail().config(
			from=settings.sendEmailFrom,
			to=user.getEmail(),
			subject="#user.getName()# Posted in #topic.getTitle()#",
			timeout="120"
		);
				
		/** 
		 * Set tokens within the mail object. The tokens will be evaluated
		 * by the ColdBox Mail Service. Any matching @key@ within the view
		 * will be replaced with the token's value
		 */
		local.email.setBodyTokens({
			author = user.getName(),
			topicTitle = topic.getTitle(),
			url = baseURL & "forums/replies/" & topic.getTopicID()
		});
		
		// Add HTML email
		local.email.addMailPart(charset='utf-8',type='text/html',body=renderer.renderView(view=emailView,module="SigmaForums"));
		
		// Send the email. MailResult is a boolean.
		local.mailResult = mailService.send(local.Email);

	}



	/*  pseudo-code for... something, not sure since im just minicing an old app's codebase
	public void function onOff(required string topicid, required string userid) {
		var subscription = new(arguments);
		if( exists(subscription) ) {
			remove(subscription);
		} else {
			save(subscription);
		}
	}
	
	public void function resetUserTriggers(required string userid, trigger=fale) {
		var subscriptions = getBy(userid=userid);
		var thissub = '';
		for(thissub in subscriptions) {
			thissub.setSentTrigger(arguments.trigger);
			thissub.save();
		}
	}
	*/
	


}



/*
	<cffunction name="send" access="public" output="true" returntype="void">
		<cfargument name="reply" type="com.forums.reply">
		<cfargument name="authUser" type="com.user.user" required="true" />
		<cfset var subscriptions = getBy(
			referenceID=arguments.reply.getTopicID(),
			sentTrigger=false
		) />
		<cfset var thisSubscription = "" />
		<cfset var sendToUser = "" />
		<cfset var userNotifySettings = "" />
		<cfset var notifySettingService = THIS.getNotifySettingService() />
		<cfset var userService = THIS.getUserService() />
		<cfset var emailerService = THIS.getEmailerService() />

		<cfloop array="#subscriptions#" index="thisSubscription">
			<cfif arguments.authUser.getUserID() NEQ thisSubscription.getUserID()>
				<cfif NOT THIS.get(thisSubscription.getReferenceID(),thisSubscription.getUserID()).getSentTrigger()>

					<cfset sendToUser = userService.get( thisSubscription.getUserID() ) />
					<cfset emailerService.mail( sendToUser,arguments.reply ) />
					<cfset thisSubscription.setSentTrigger(true) />
					<cfset thisSubscription.save() />
					<cfif NOT notifySettingService.get(thisSubscription.getUserID()).getOnPerTopic()>
						<cfset THIS.resetUserTriggers(sendToUser,true) />
					</cfif>

				</cfif>
			</cfif>
		</cfloop>

	</cffunction>
	*/