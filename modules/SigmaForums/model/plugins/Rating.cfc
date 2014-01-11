component persistent="true" table="forum_ratings" scope="singleton" {

	property name="replyid"			type="string"	fieldtype="id"		ormtype="string"	notnull="true"	length="60"	generator="assigned";
	property name="userid"			type="string"	fieldtype="id"		ormtype="string"	notnull="true"	length="60"	generator="assigned";
	property name="rateIndex"		type="numeric"	default="0";
	property name="created"			ormtype="timestamp" notnull="true";
	property name="target_userid"	ormtype="string"	notnull="true";

}