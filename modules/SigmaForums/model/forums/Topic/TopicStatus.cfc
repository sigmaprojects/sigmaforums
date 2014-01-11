/*
	really, this is mainly here for orm to create the table
*/
component persistent="true" table="forum_topic_status"{

	property name="userid"		type="string"	fieldtype="id"	ormtype="string"   	notnull="true"	generator="assigned";
	property name="topicid"		type="numeric"	fieldtype="id"	ormtype="int"		notnull="true"	generator="assigned";
	property name="created" 	ormtype="timestamp" notnull="true";

}