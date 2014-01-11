<cfoutput>
	<div class="editprofile_nav">
		<div>
			<h5>Subscriptions</h5>
			<div class="topbg">
				<a href="#event.buildLink('forums.users.editNotifications')#">View Options</a>  
			</div>
		</div>

		<div>
			<h5>Personal Profile</h5>
			<div class="topbg">
				<a href="#event.buildLink('forums.users.editprofile')#">Edit Profile Info</a>  <br />
				<a href="#event.buildLink('forums.users.editsignature')#">Edit Signature / Avatar</a>
			</div>
		</div>
<!---
		<div>
			<h5>Options</h5>
			<div class="topbg">
				<a href="#event.buildLink('forums.users.emailsettings')#">Email Settings</a>  <br />
				<a href="#event.buildLink('forums.users.boardsettings')#">Board Settings</a>
			</div>
		</div>
--->
	</div>
</cfoutput>