/*
	buggin out to sql for most of this, cuz it'll will get hairy fast.
	this is where 'topic status' and etc will be implemented in the future.
*/
component singleton {
	
	public ForumStatusService function init(){
		return this;
	}



	public boolean function getTopicCount(string TopicID='', string UserID='') {
		var query = new query(); 
		query.setDatasource("sigmaforums"); 
		query.setName("checkStored"); 
		query.addParam(name="userid",value="#Arguments.UserID#",cfsqltype="VARCHAR"); 
		query.addParam(name="referenceid",value="#Arguments.TopicID#",cfsqltype="VARCHAR"); 
		var result = query.execute(sql="SELECT count(1) FROM forum_topics WHERE referenceID = :referenceID and userid = :userid"); 
		var checkStored = result.getResult(); 
		var metaInfo = result.getPrefix();
		writedump(result);
		writedump(checkStored);
		writedump(metaInfo);
		abort;
	}

	//move this to rpely service
	public numeric function getUserReplyCount(string UserID='') {
		var query = new query(); 
		query.setDatasource("sigmaforums"); 
		query.setName("userReplyCount"); 
		query.addParam(name="userid",value="#Arguments.UserID#",cfsqltype="VARCHAR");  
		var result = query.execute(sql="SELECT count(1) as ReplyCount FROM forum_replies WHERE user_id = :userid"); 
		var userReplyCount = result.getResult(); 
		var metaInfo = result.getPrefix();
		writedump(result);
		writedump(userReplyCount);
		writedump(metaInfo);
		abort;
	}
	
	public string function getTopicStatusForUser(topicid,userid='') {
		var returnStatus = variables.statusIcons.old;
		if( Len(arguments.userid) == 0) {
			return returnStatus;
		}
		if( hasUserRepliedInTopic(arguments.topicid,arguments.userid) ) {
			if( isTopicOld(arguments.topicid) ) {
				returnStatus = variables.statusIcons.oldMe;
			}
			else {
				if( isTopicStatusStoredForUser(arguments.topicid,arguments.userid) ) {
					returnStatus = variables.statusIcons.oldMe;
				}
				else {
					returnStatus = variables.statusIcons.newMe;
				}
			}
		}
		else {
			if( isTopicOld(arguments.topicUUID) eq true ) {
				returnStatus = variables.statusIcons.old;
			}
			else {
				if( isTopicStatusStoredForUser(arguments.topicid,arguments.userid) eq true ) {
					returnStatus = variables.statusIcons.old;
				}
				else {
					returnStatus = variables.statusIcons.new;
				}
			}
		}
		// append here for future 'locked topics' ie: isTopicLocked(id) return locked icon
		return returnStatus;
	}

	
	public boolean function isTopicStatusStoredForUser(topicid,userid) {
		//check if the topicid and userid is in forum_status, return true if so
	}

	public void function saveStoredTopicStatusForUser(topicid,userid='') {
		//insert into forum_status, topicid,userid,created
	}

	public void function removeStoredTopicStatusForUser(topicid,userid) {
		//remove from forum_status where topicid= and userid=
	}

	public void function resetStoredTopicStatus(topicid) {
		//delete from forum_status where topicid=
	}


	public any function getSectionStatusForUser(sectionid,userid) {
		var sectionTopics = getTopicsBySection(arguments.sectionid);
		var returnStatus = variables.statusIcons.old;
		var i = 1;
		for(i=1;i<=ArrayLen(sectionTopics);i++) {
			if( getTopicStatus() contains 'green' ) {
				returnStatus = variables.statusIcons.new;
				break;
			}
		}
		return returnStatus;
	}


}