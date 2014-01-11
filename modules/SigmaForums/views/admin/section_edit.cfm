<cfoutput>

<h6>Edit / Create a Section</h6>
<div class="form">
	<form action="#event.buildLink('admin.saveSection')#" method="post" enctype="multipart/form-data">
		<cfif IsNumeric(rc.section.getsectionid())>
			<input name="sectionid" type="hidden" value="#rc.section.getsectionid()#" />
		</cfif>

		<ol>
			<li>
				<label for="areaid">Area:<span class="red">*</span></label>
				<select name="areaid" id="areaid">
					
					<!--- this is gonna get real annoying, real quick --->
					<cfloop array="#rc.areas#" index="area">
						<option value="#area.getAreaID()#"<cfif rc.section.hasArea() and area.getAreaID() EQ rc.section.getArea().getAreaID() or !IsNull(rc.areaID) and rc.areaID eq area.getAreaID()> selected="selected"</cfif>>
							#area.getTitle()#
						</option>
					</cfloop>
				</select>
			</li>
			<li>
				<label for="title">Section Title:<span class="red">*</span></label>
				<input type="text" name="title" id="title" value="#rc.section.getTitle()#" />
			</li>
			<li>
				<input type="submit" class="submit" value="Save" />
				<div class="clr"></div>
			</li>
		</ol>
	
	</form>
</div>


</cfoutput>