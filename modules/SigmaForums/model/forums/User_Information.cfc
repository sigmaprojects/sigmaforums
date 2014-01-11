component persistent="true" accessors="true"  table="forum_userinformation" scope="singleton"{

	property name="timezoneService"	inject="coldbox:myPlugin:timezoneService@SigmaForums" persistent="false";

	
	property name="userid" fieldtype="id" generator="foreign" params="{property='user'}"; 
	property name="user" persistent="true" fieldtype="one-to-one" cfc="solitary.model.users.User" fkcolumn="user_id" fetch="join" notnull="true" cascade="all" inverse="true" ;
	
	property name="created"	ormtype="timestamp" notnull="true";

	property name="auto_subscribe" type="boolean" default="true" ormtype="boolean" sqltype="smallint" length="1" notnull="true";
	property name="contact_email" type="string" required="false";
	
	
	property name="contact_aim" type="string" required="false";
	property name="contact_twitter" type="string" required="false";
	property name="contact_facebook" type="string" required="false";
	property name="contact_yahoo" type="string" required="false";
	property name="contact_website" type="string" required="false";
	property name="contact_msn" type="string" required="false";
	property name="timezone" type="string" required="false";

	property name="birthday" type="date" required="false";
	property name="location" type="string" required="false";
	property name="interests" type="string" required="false";
	property name="occupation" type="string" required="false";

	property name="signature" type="string" required="false";
	property name="avatar" type="binary" required="false" length="999999" ;
	
	property name="replyCount" formula="select count(forum_replies.replyid) from forum_replies where forum_replies.user_id = userid";

	//Requires Rating plugin
	property name="reputation" formula="select sum(forum_ratings.rateIndex) from forum_ratings where forum_ratings.target_userid = userid";
	public numeric function getReputation() {
		if(IsNull(variables.reputation) || !IsNumeric(variables.reputation)) {
			return 0;
		}
		return variables.reputation;
	}

	public string function gettimezoneOffset() {
		if(!StructKeyExists(variables,'timezoneOffset')) {
			variables.timezoneOffset = timezoneService.getTZOffset(Now(),getTimeZone());
		}
		return variables.timezoneOffset;
	}

	public any function ulDateTimeFormat(required any serverTime, string mask='medium') {
		var returnDateTime = "#DateFormat(arguments.serverTime,arguments.mask)# #TimeFormat(arguments.serverTime,arguments.mask)#";
		try {
			returnDateTime = "#ulDateFormat(arguments.serverTime,arguments.mask)# #ulTimeFormat(arguments.serverTime,arguments.mask)#";
		} catch(e Any) {}
		return returnDateTime;
	}
	
	public any function ulTimeFormat(required any serverTime, string mask='medium') {
		var userTime = arguments.serverTime;
		try {
			//userTime = DateConvert('Utc2local',userTime);
			userTime = dateAdd("h", gettimezoneOffset() + GetTimeZoneInfo().utcHourOffset , userTime);
			userTime = timeFormat(userTime,arguments.mask);
		} catch(e Any) {}
		return userTime;
	}
	
	public any function ulDateFormat(required any serverDate, string mask='medium') {
		var userDate = arguments.serverDate;
		try {
			//userDate = DateConvert('Utc2local',userDate);
			userDate = dateAdd("h", gettimezoneOffset() + GetTimeZoneInfo().utcHourOffset , userDate);
			userDate = dateFormat(userDate,arguments.mask);
		} catch(e Any) {}
		return userDate;
	}
	
	public any function ulSystemDateTime(required any sysDateTime) {
		try {
			//arguments.sysDateTime = DateConvert('Utc2local',arguments.sysDateTime);
			arguments.sysDateTime = DateAdd("h", gettimezoneOffset() + GetTimeZoneInfo().utcHourOffset,arguments.sysDateTime);
			arguments.sysDateTime = ParseDateTime(arguments.sysDateTime);
		} catch(e Any) {}
		return arguments.sysDateTime;
	}



}