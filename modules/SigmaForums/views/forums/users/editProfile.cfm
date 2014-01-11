<cfoutput>

	#renderView( view='forums/users/_inc_leftnav' )# 

	<div class="editprofile_content">
		
		<h5>Your personal profile [optional]</h5>
		
		
		<div class="form">
			<cfform action="#event.buildLink('forums.users.editProfile.saveProfile')#" method="post" enctype="multipart/form-data">
			<cfif isDate(rc.userInformation.getBirthday())>
				<cfset tmpd = DateFormat(rc.userInformation.getBirthday(),'mm/dd/yyyy') />
			<cfelse>
				<cfset tmpd = '05/05/1900' />
			</cfif>
			
				<ol>
					<li>
						<label for="birthday">Birthday:</label>
						<cfinput type="datefield" name="birthday" id="birthday" size="11" mask='mm/dd/yyyy' value="#tmpd#"/>
						 <div class="clr"></div>
					</li>
					<li>
						<label for="timezone">TimeZone:</label>
							<cfset tzService = getMyPlugin('timeZoneService',false,'SigmaForums') />
							<select name="timezone" id="timezone">
								<cfloop array="#tzService.getAvailableTZ()#" index="timezone">
									<option value="#trim(timezone)#" <cfif trim(timezone) eq trim(rc.userInformation.getTimeZone())>selected="selected"</cfif>>
										<cfif tzService.getRawOffset(trim(timezone)) gte 0>+</cfif>#tzService.getRawOffset(trim(timezone))# &nbsp; &nbsp; #trim(timezone)#
									</option>
								</cfloop>
							</select>
						 <div class="clr"></div>
					</li>
					<li>
						<label for="contact_website">Website:</label>
						<input type="text" name="contact_website" id="contact_website" value="#rc.userInformation.getContact_Website()#" />
					</li>
					<li>
						<label for="contact_twitter">Twitter:</label>
						<input type="text" name="contact_twitter" id="contact_twitter" value="#rc.userInformation.getContact_Twitter()#" />
					</li>
					<li>
						<label for="contact_facebook">Facebook:</label>
						<input type="text" name="contact_facebook" id="contact_facebook" value="#rc.userInformation.getContact_Facebook()#" />
					</li>
					<li>
						<label for="contact_aim">AIM:</label>
						<input type="text" name="contact_aim" id="contact_aim" value="#rc.userInformation.getContact_AIM()#" />
					</li>
					<li>
						<label for="contact_yahoo">Yahoo:</label>
						<input type="text" name="contact_yahoo" id="contact_yahoo" value="#rc.userInformation.getContact_Yahoo()#" />
					</li>
					<li>
						<label for="contact_msn">MSN:</label>
						<input type="text" name="contact_msn" id="contact_msn" value="#rc.userInformation.getContact_MSN()#" />
					</li>
					<li>
						<label for="location">Location:</label>
						<input type="text" name="location" id="location" value="#rc.userInformation.getLocation()#" />
					</li>
					<li>
						<label for="occupation">Occupation:</label>
						<input type="text" name="occupation" id="occupation" value="#rc.userInformation.getOccupation()#" />
					</li>
					<li>
						<label for="interests">Interests:</label>
						<textarea name="interests" id="interests">#rc.userInformation.getInterests()#</textarea>
					</li>

					<li>
						<input type="submit" class="submit" value="Save" />
						<div class="clr"></div>
					</li>
				</ol>
	
			</cfform>
		</div>
		
		
	</div>
		

</cfoutput>