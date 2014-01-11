<cfoutput>

	#renderView( view='forums/users/_inc_leftnav' )# 

	<div class="editprofile_content" style="width:50%;">
		
		<h5>Options</h5>
		
		
		<div class="form">
			<cfform action="#event.buildLink('forums.users.editProfile.saveProfile')#" method="post" enctype="multipart/form-data">

				<ol>
					<li>
						<label for="auto_subscribe">Auto Subscribe:</label>
						<input type="checkbox" name="auto_subscribe" id="auto_subscribe" value="true" <cfif rc.userInformation.getAuto_Subscribe()>checked="true"</cfif> />
					</li>
					<li>
						Enabling this option will automaticly subscribe you to any topic you start or reply to.
					</li>
					<li>
						<input type="submit" class="submit" value="Save" />
						<div class="clr"></div>
					</li>
				</ol>
	
			</cfform>
		</div>
		
		<h5>Subscriptions</h5>
		
		<div>
			<cfloop array="#rc.subscriptions#" index="sub">
				<a href="#event.buildLink('forums.users.editRemoveSubscription/topicid/#sub.getTopicID()#')#">
					<img src="#event.getModuleRoot()#/includes/images/icons/16-em-cross.png">
				</a>
				<a href="#event.BuildLink('forums.replies/#sub.getTopicID()#/#sub.getTopic_Title()#')#">#sub.getTopic_Title()#</a>
				&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;  
			</cfloop>
		</div>
		
		
	</div>
		

</cfoutput>