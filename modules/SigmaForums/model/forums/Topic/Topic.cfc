component persistent="true" table="forum_topics" {

	property name="topicid" ormtype="integer" fieldtype="id" generator="native" generated="insert";
	property name="created" ormtype="timestamp" notnull="true";
	property name="updated" ormtype="timestamp" notnull="true";
	property name="title" type="string" required="true" notnull="true";
	
	property name="views" type="numeric" default="0" ;
	property name="replyCount" formula="(select count(1) from forum_replies where forum_replies.topicid = topicid)";
	
	//why cant another entity order by a calculated property?  why bloat to workaround?  lame
	//property name="lastPost" formula="(select forum_replies.created from forum_replies where forum_replies.topicid = topicid order by forum_replies.created desc LIMIT 1)";
	property name="lastPost" ormtype="timestamp" notnull="true";
	
	property name="section" fieldtype="many-to-one" fkcolumn="sectionid" cfc="SigmaForums.model.forums.Section.Section" missingRowIgnored="false";
	property name="section_id" column="sectionid" insert="false" update="false";

	property name="replies" singularName="reply" type="array" fieldtype="one-to-many" cfc="SigmaForums.model.forums.Reply.Reply" fkcolumn="topicid" inverse="true" cascade="all-delete-orphan" orderby="created desc";


	property name="user" persistent="true" fieldtype="many-to-one" cfc="solitary.model.users.User" fkcolumn="user_id" fetch="join" notnull="true" cascade="all";



	public any function getLastReply() {
		if(ArrayLen(this.getReplies())) {
			return this.getReplies()[1];
		}
	}
	
	/*
	public numeric function getReplyCount() {
		return ArrayLen(this.getReplies());
	}
	public any function getAuthor() {
		return '';
	}
	*/
}