<cfoutput>

	<table class="forums" cellspacing="10">
		<tfoot>
			<tr>
				<th class="status">&nbsp;</th>
				<th class="title">&nbsp;</th>
				<th class="author">Author</th>
				<th class="count">Replies</th>
				<th class="count">Views</th>
				<th class="last">Last Post</th>
			</tr>
			<tr>
				<th class="paging" colspan="6">
					#rc.Paging.renderit(rc.count, event.buildLink('forums.topics/#rc.section.getSectionID()#/#rc.Section.getTitle()#/page/@page@') )#
				</th>
			</tr>
		</tfoot>
		<tbody>
			<tr>
				<td class="header" colspan="6">
					<div style="width:80%; float:left;">
					#getMyPlugin("Crumbs",true,'SigmaForums').renderIt()#
					</div>
					<a class="button" href="#event.BuildLink('forums.editTopic/#rc.Section.getSectionID()#')#">
						<span>New Topic</span>
					</a>
				</td>
			</tr>

			<cfloop array="#rc.topics#" index="Topic">
				<tr>
					<td class="status topics">
						<img src="#event.getModuleRoot()#/includes/images/topicstatus/#rc.TopicStatusService.getTopicStatusForUser( Topic.getTopicID(), rc.userid )#">
					</td>
					<td class="title">
						<a href="#event.BuildLink('forums.replies/#Topic.getTopicID()#/#Topic.getTitle()#')#">#Topic.getTitle()#</a>
					</td>
					<td class="author">
						#Topic.getUser().getName()#
					</td>
					<td class="count">
						#Topic.getReplyCount()#
					</td>
					<td class="count">
						#Topic.getViews()#
					</td>
					<td class="topiclast">
						<cfif !IsNull( Topic.getLastReply() )>
							By: #Topic.getLastReply().getUser().getName()#
							<br />
							#Topic.getLastReply().getUserInformation().ulDateTimeFormat(Topic.getLastReply().GetCreated(),'medium')#
						</cfif>
					</td>
				</tr>
			</cfloop>
		</tbody>
	</table>
		

</cfoutput>