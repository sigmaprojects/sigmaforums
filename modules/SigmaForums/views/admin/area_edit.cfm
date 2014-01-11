<cfoutput>

<h6>Edit / Create an Area</h6>
<div class="form">
	<form action="#event.buildLink('admin.saveArea')#" method="post" enctype="multipart/form-data">
		<cfif IsNumeric(rc.area.getareaid())>
			<input name="areaid" type="hidden" value="#rc.area.getareaid()#" />
		</cfif>
		
		<ol>
			<li>
				<label for="title">Area Title:<span class="red">*</span></label>
				<input type="text" name="title" id="title" value="#rc.area.getTitle()#" />
			</li>
			<li>
				<input type="submit" class="submit" value="Save" />
				<div class="clr"></div>
			</li>
		</ol>
	
	</form>
</div>


</cfoutput>