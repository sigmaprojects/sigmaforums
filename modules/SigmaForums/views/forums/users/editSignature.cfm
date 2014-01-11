<cfoutput>

	#renderView( view='forums/users/_inc_leftnav' )# 

	<div class="editprofile_content">
		
		<h5>Avatar & Signature</h5>
		
		
		<div class="form">
			<form action="#event.buildLink('forums.users.editProfile.saveProfile')#" method="post" enctype="multipart/form-data">
			
				<ol>
					<li>
						<label for="signature">Signature:</label>
						<textarea name="signature" id="signature">#rc.userInformation.getSignature()#</textarea>
					</li>

					<li>
						<label for="avatar">Avatar:</label>
						<input type="file" name="avatar___file" />
						<br>
						<cftry><cfimage action="writeToBrowser" source="#rc.userInformation.getAvatar()#"><cfcatch></cfcatch></cftry>
					</li>
					<li>
						<br />
					</li>
					<li>
						<input type="submit" class="submit" value="Save" />
						<div class="clr"></div>
					</li>
				</ol>
	
			</form>
		</div>
		
		
	</div>
		

</cfoutput>