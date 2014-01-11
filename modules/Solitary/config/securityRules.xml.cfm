<?xml version="1.0" encoding="UTF-8"?>
<!--
Declare as many rule elements as you want, order is important 
Remember that the securelist can contain a list of regular
expression if you want

ex: All events in the user handler
 user\..*
ex: All events
 .*
ex: All events that start with admin
 ^admin

If you are not using regular expression, just write the text
that can be found in an event.
-->
<rules>
    <rule>
        <whitelist>
        	solitary:security\..*,
			docs\..*,
			SigmaForums:forums\.index,
			SigmaForums:forums\.topics,
			SigmaForums:forums\.areas,
			SigmaForums:forums\.replies
		</whitelist>
        <securelist>solitary:user\..*,solitary:roles\..*</securelist>
        <roles>admin</roles>
        <permissions></permissions>
        <redirect>security/login</redirect>
		<useSSL>false</useSSL>
    </rule>
    <rule>
        <whitelist>
        	solitary:security\..*,
			docs\..*,
			SigmaForums:forums\.index,
			SigmaForums:forums\.topics,
			SigmaForums:forums\.areas,
			SigmaForums:forums\.replies
        </whitelist>
        <securelist>
			SigmaForums:forums\.editreply,
			SigmaForums:forums\.savereply,
			SigmaForums:forums\.edittopic,
			SigmaForums:forums\.savetopic
		</securelist>
        <roles>user,admin,moderator</roles>
        <permissions></permissions>
        <redirect>forums.index</redirect>
    </rule>
</rules>
<!--
<rules>
    <rule>
        <whitelist>user\.login,user\.logout,^main.*</whitelist>
        <securelist>^user\..*, ^admin</securelist>
        <roles>admin</roles>
        <permissions>read,write</permissions>
        <redirect>user.login</redirect>
    </rule>

    <rule>
        <whitelist></whitelist>
        <securelist>^moderator</securelist>
        <roles>admin,moderator</roles>
        <permissions>read</permissions>
        <redirect>user.login</redirect>
    </rule>
</rules>
-->
