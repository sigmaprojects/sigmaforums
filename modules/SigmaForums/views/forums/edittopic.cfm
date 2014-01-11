<cfoutput>

<cfset addAsset(event.getModuleRoot() & "/includes/javascript/rte/jquery.rte.js") />
<cfset addAsset(event.getModuleRoot() & "/includes/javascript/rte/jquery.rte.tb.js") />
<cfset addAsset(event.getModuleRoot() & "/includes/javascript/rte/jquery.rte.css") />

<script type="text/javascript">
$(document).ready(function() {
	$('.rte').rte({
		width: 900,
		height: 200,
		controls_rte: rte_toolbar,
		controls_html: html_toolbar
	});
});
</script>


	<h6>Creating / Editing Topic in #rc.Section.getTitle()#<strong></strong></h6>

	<div class="form">
		<cfform name="editTopic" action="#event.BuildLink('forums.saveTopic')#">
			<cfif IsNumeric(rc.topic.getTopicID())>
				<input name="topicID" type="hidden" value="#rc.topic.getTopicID()#" />
			</cfif>

			<ol>
				<li>
					<label for="sectionID">Section:<span class="red">*</span></label>
					<select name="sectionID" id="sectionID">
						<cfloop array="#rc.sections#" index="Section">
							<option value="#Section.getSectionID()#"<cfif rc.Topic.hasSection() && rc.Topic.getSection().getSection() EQ rc.SectionID OR Section.getSectionID() EQ rc.Section.getSectionID()> selected="selected"</cfif>>
								#Section.getTitle()#
							</option>
						</cfloop>
					</select>
				</li>
				<li>
					<label for="title">Topic Title:<span class="red">*</span></label>
					<input type="text" name="title" id="title" value="#rc.Topic.getTitle()#" />
				</li>
				<li>
					<!---
					<cftextarea richtext="true" name="content" id="content" skin="office2003" value="#event.getValue('content','')#" />
					--->
					<textarea name="content" id="content" class="rte">#event.getValue('content','')#</textarea>
				</li>
				<li>
					<input type="submit" class="submit" value="Post" />
					<div class="clr"></div>
				</li>
			</ol>
	
		</cfform>
	</div>



</cfoutput>