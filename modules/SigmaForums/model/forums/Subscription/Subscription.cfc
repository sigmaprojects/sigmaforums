component persistent="true" table="forum_subscriptions" scope="singleton" {

	property name="topicid"		type="string"	fieldtype="id"		ormtype="string"	notnull="true"	length="60"	generator="assigned";
	property name="userid"		type="string"	fieldtype="id"		ormtype="string"	notnull="true"	length="60"	generator="assigned";
	property name="sent"		type="boolean"	default="true"		ormtype="boolean"	sqltype="smallint"	length="1"	notnull="true";
	property name="created"		ormtype="timestamp" notnull="true";


	//isnt ORM stuff coooool?
	property name="user_email" formula="(SELECT users.email from users where users.user_id = userid)";
	property name="user_name" formula="(SELECT concat(users.firstname, ' ', users.lastname) from users where users.user_id = userid)";
	property name="topic_title" formula="(SELECT forum_topics.title from forum_topics where forum_topics.topicid = topicid)";
}