<cfoutput>

	<table class="forums" cellspacing="10">
		<tfoot>
			<tr>
				<th class="status">&nbsp;</th>
				<th class="title">&nbsp;</th>
				<th class="count">Topics</th>
				<th class="count">Replies</th>
				<th class="last">Last Post</th>
			</tr>
		</tfoot>
		<tbody>
			<cfloop array="#rc.areas#" index="Area">
				<tr>
					<td class="header" colspan="6">
						<h6>#Area.getTitle()#</h6>
					</td>
				</tr>
				<cfloop array="#Area.getSections()#" index="Section">
					<tr>
						<td class="status">
							<img src="#event.getModuleRoot()#/includes/images/topicstatus/#rc.TopicStatusService.getSectionStatusForUser( Section , rc.userid )#">
						</td>
						<td class="title">
							&nbsp; &nbsp; &nbsp; <a href="#event.BuildLink('forums.topics/#Section.getSectionID()#/#Section.getTitle()#')#">#Section.getTitle()#</a>
						</td>
						<td class="count">
							#Section.getTopicCount()#
						</td>
						<td class="count">
							#Section.getRepliesCount()#
						</td>
						<td class="last">
						<cfif !IsNull( Section.getLastTopic() )>
							<cfset lastTopic = Section.getLastTopic() />
							In: <a href="#event.buildLink('forums.replies/#lastTopic.getTopicID()#/#lastTopic.getTitle()#')#">#lasttopic.getTitle()#</a>
							<br />
							By: <a href="#event.buildLink('forums.profile/#lastTopic.getLastreply().getUser_ID()#')#">#lastTopic.getLastreply().getUser().getName()#</a>
						</cfif>
						</td>
					</tr>
				</cfloop>
			</cfloop>
		</tbody>
	</table>

</cfoutput>