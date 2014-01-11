/*
	might be, maybe, better to bug out to sql for most of this, cuz it'll will get hairy fast.
	this is where 'topic status' and etc will be implemented in the future.
	Honestly, i want to just pass whole Topic, User, and etc objects into these functions but
	since im still using Solitary... have fun!
*/
component extends="coldbox.system.orm.hibernate.VirtualEntityService" singleton {


	public TopicStatusService function init(
		topicService="" inject="model:topicService@SigmaForums"
	){
		super.init(entityName="TopicStatus");
		variables.dsn = 'sigmaforums';
		
		return this;
	}



	// would like to manage this better, rather then just string reps of images
	public string function getTopicStatusForUser(topicid,userid='') {
		var returnVal = '16-circle-blue.png';
		if( Len(arguments.userid) == 0) {
			return returnVal;
		}
		if(NOT IsNumeric(arguments.topicid)) {
			return returnVal;
		};
		var isTopicStatusStoredForUser = isTopicStatusStoredForUser(arguments.topicid,arguments.userid);
		var hasUserRepliedInTopic = hasUserRepliedInTopic(arguments.topicid,arguments.userid);
		var isTopicOld = isTopicOld(arguments.topicid);
		
		if(hasUserRepliedInTopic) {
			if(isTopicOld) {
				returnVal='16-circle-blue-check.png';
			}
			else {
				if(isTopicStatusStoredForUser) {
					returnVal='16-circle-blue-check.png';
				}
				else {
					returnVal='16-circle-green-check.png';
				};
			};
		} else {
			if(isTopicOld) {
				returnVal='16-circle-blue.png';
			}
			else {
				if(isTopicStatusStoredForUser) {
					returnVal='16-circle-blue.png';
				}
				else {
					returnVal='16-circle-green.png';
				};
			};
		};
		/* so not done yet, cuz it kind of involves user management stuffs like moderators
		if( isTopicLocked ) {
			returnVal='16-security-lock.png';
		};
		if( isTopicSticky) {
			if( isTopicOld ) {
				returnVal='16-paper-clip.png';
			}
			else {
				if(isTopicStatusStoredForUser) {
					returnVal='16-paper-clip.png';
				}
				else {
					returnVal='16-paper-clip-green.png';
				};
			};
		};
		*/

		return returnVal;
	}

	public any function getSectionStatusForUser(section,userid) {
		var sectionTopics = arguments.section.getTopics();
		var returnVal = '16-circle-blue.png';
		var i = 1;
		for(i=1;i<=ArrayLen(sectionTopics);i++) {
			if( getTopicStatusForUser( sectionTopics[i].getTopicID(), arguments.userid ) contains 'green' ) {
				returnVal = '16-circle-green.png';
				break;
			}
		}
		return returnVal;
	}
	
	public boolean function isTopicStatusStoredForUser(topicid,userid) {
		// uh, coldbox's BaseORMService cant do exists on multi-id's like this yet, so...
		var count = ORMExecuteQuery("select count(*) as Count from TopicStatus where topicid = :topicid AND userid = :userid",arguments,true);
		return YesNoFormat(count); //where's the TrueFalseFormat?
	}


	//called when a logged in user gets replies (views a topic)
	public void function saveStoredTopicStatusForUser(topicid,userid='') {
		if( Len(arguments.userid) ) {
			var TopicStatus = super.New(argumentCollection=arguments);
			TopicStatus.setCreated( Now() );
			super.Save( TopicStatus );
		}
	}

	public void function removeStoredTopicStatusForUser(required string topicid,required string userid) {
		ORMExecuteQuery("delete from TopicStatus where topicid = :topicid AND userid = :userid",arguments,true);
	}

	public void function resetStoredTopicStatus(topicid) {
		ORMExecuteQuery("delete from TopicStatus where topicid = :topicid ",arguments,true);
	}



	public boolean function hasUserRepliedInTopic(topicid,userid='') {
		var count = ORMExecuteQuery("SELECT count(topic_id) FROM Reply WHERE topic_id = :topicid AND user_id = :userid ",arguments,true);
		return YesNoFormat(count);
	}


	//hard coded date here, should be moved to 'settings'
	public boolean function isTopicOld(topicid) {
		var TopicCreated = ORMExecuteQuery("SELECT created FROM Reply WHERE topic_id = :topicid ORDER BY created DESC",arguments,true,{maxresults=1});

		// in a try, cuz really, dates can sometimes be unpredictable
		try {
			if( DateDiff("d", DateFormat( TopicCreated ), Now()) GT 4 ) {
				return true;
			} else {
				return false;
			}
		} catch(Any e) {
			return true;
		}
	}
}