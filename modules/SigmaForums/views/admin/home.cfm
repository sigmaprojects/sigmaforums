<cfoutput>

	
	<cfloop array="#rc.areas#" index="Area">
		<h6>
			#Area.getTitle()#
			
			<div style="float:right;">
				<a href="#event.buildLink('admin.editArea/areaid/#Area.getAreaID()#')#">[edit]</a>  &nbsp;
				<a href="#event.buildLink('admin.editSection/areaid/#Area.getAreaID()#')#">[add section]</a>  &nbsp;
				&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
				[delete]
			</div>
		</h6>
		<table class="forums">
			<cfloop array="#Area.getSections()#" index="Section">
				<tr>
					<td>
						&nbsp; &nbsp; &nbsp; #Section.getTitle()#
					</td>
					<td width="130" align="middle">
						<a href="#event.buildLink('admin.editSection/areaid/#Section.getArea().getAreaID()#/sectionid/#Section.getSectionID()#')#">[edit section]</a>
					</td>
				</tr>
			</cfloop>
		</table>
		
		<hr />
	</cfloop>




</cfoutput>