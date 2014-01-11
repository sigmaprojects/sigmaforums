component persistent="true" table="forum_sections" accessors="true" {

	property name="sectionid" ormtype="integer" fieldtype="id" generator="native" generated="insert";
	property name="created" ormtype="timestamp" notnull="true";
	property name="updated" ormtype="timestamp" notnull="true";
	property name="title" type="string" required="true" notnull="true";
	property name="views" type="numeric" default="0" ;
	
	property name="area" fieldtype="many-to-one" fkcolumn="areaid" cfc="SigmaForums.model.forums.Area.Area" missingRowIgnored="false";

	property name="topics" singularName="topic" type="array" fieldtype="one-to-many" cfc="SigmaForums.model.forums.Topic.Topic" fkcolumn="sectionid" inverse="true" cascade="all-delete-orphan" orderby="lastPost desc";

	//property name="ReplyCount" type="numeric" default="0" formula="SELECT count(1) as ReplyCount FROM forum_replies WHERE forum_ratings.replyid = replyid";
	
	//property name="rateIndex" type="numeric" default="0" formula="SELECT SUM(rateIndex) as rateIndexSum FROM forum_ratings WHERE forum_ratings.replyid = replyid";
	
	public Section function init() {
		return This;
	}


	public numeric function getTopicCount() {
		return ArrayLen(this.getTopics());
	}

	public numeric function getRepliesCount() {
		var topics = this.getTopics();
		var replyCount = 0;
		var i = 1;
		for(i=1;i <= ArrayLen(topics);i++) {
			replyCount = replyCount+ArrayLen(topics[i].getReplies());
		}
		return replyCount;
	}


	public any function getLastTopic() {
		if(ArrayLen(this.getTopics())) {
			return this.getTopics()[1];
		}
		
	}
}