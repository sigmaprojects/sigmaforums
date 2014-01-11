<cfset addAsset(event.getModuleRoot() & "/includes/javascript/plugins/Rating.js") />
<cfset addAsset(event.getModuleRoot() & "/includes/styles/plugins/Rating.css") />

<cfoutput>

 	<div id="forum-head">
 		<div id="a">
			#getMyPlugin("Crumbs",true,'SigmaForums').renderIt()#
		</div>
		<div id="b">
			<a class="button" href="#event.BuildLink('forums.editReply/#rc.Topic.getTopicID()#')#">
				<span>Add Reply</span>
			</a>
		</div>
		<div id="c">
			#rc.Paging.renderit(rc.count, event.buildLink('forums.replies/#rc.Topic.getTopicID()#/#rc.Topic.getTitle()#/page/@page@') )#
		</div>
		<div class="clear-all"></div><br />
	</div>
 
 
 	<div class="clear-all"></div><br /> 
 
	<cfloop array="#rc.Replies#" index="Reply">
		<cfset RelativePostedDate = Reply.getUserInformation().ulDateFormat(Reply.GetCreated(),'mm/d/yy') />
		<cfset RelativePostedTime = Reply.getUserInformation().ulTimeFormat(Reply.GetCreated(),'h:mm tt') />
		<cfset timeIndicatorDate = Reply.getUserInformation().ulTimeFormat(Reply.GetCreated(),'h:mm tt') />

		<a name="96F98220-3048-5F25-7CD8D78833C89576"></a>
		<div class="replies-container">
			<div class="reply-header">
				<span class="posted">
					<img src="#event.getModuleRoot()#/includes/images/plugins/timeIndicator/#getMyPlugin('timeIndicator',false,'SigmaForums').getIcon( timeIndicatorDate )#">
					Posted: #RelativePostedDate# #RelativePostedTime#
				</span>

				<span class="rating-container" id="rating_#Reply.getReplyID()#">
					<cfif Reply.getRateIndex() GT 0>
						<cfset classColor = "rating_positive" />
					<cfelseif Reply.getRateIndex() LT 0>
						<cfset classColor = "rating_negative" />
					<cfelse>
						<cfset classColor = "rating_neutral" />
					</cfif>
					<span class="#classColor#">#Reply.getRateIndex()#</span>
					<img class="ratelink" id="#Reply.getReplyID()#" title="reply" src="#event.getModuleRoot()#/includes/images/plugins/rating/rating_up.png" alt="1" />
					<img class="ratelink" id="#Reply.getReplyID()#" title="reply" src="#event.getModuleRoot()#/includes/images/plugins/rating/rating_down.png" alt="-1" />
				</span>
			</div>
			<span class="user-container">
				<a href="#event.buildLink('forums.profile/#Reply.getUser_ID()#')#">
					<cftry>
						<cfimage action="writeToBrowser" source='#Reply.getUserInformation().getAvatar()#' >#Reply.getUser().getName()#
						<cfcatch></cfcatch>
					</cftry>
				</a> 
				<ol>
					<cfset Rep = Reply.getUserInformation().getReputation() />
					<li>Rep: <span class="#iif(Rep GTE 0,DE('rating_positive'),DE('rating_negative'))#">#Rep#</span></li>
					<li>Location: <span>#Reply.getUserInformation().getLocation()#</span></li>
					<li>Joined: <span></span></li>
					<li>Online: <span class="No">No</span></li>
					<li>Posts: <span>#Reply.getUserInformation().getReplyCount()#</span></li>
					<li>&nbsp;</li>
					<li>&nbsp;</li>
					<li>&nbsp;</li>
					<li>&nbsp;</li>
				</ol>
			</span>
			<span class="message-container">
				<div class="message">
					#Reply.getFormattedContent()#
				</div>
			</span>
			
			
			<div class="post-message-container">
				---------------------------------------
				<div class="author-signature">
					<p>
						#Reply.getUserInformation().getSignature()#
					</p>
					
				</div>
				<span class="message-controls">
					<a class="button" href="#event.buildLink('forums.editReply/#rc.Topic.getTopicID()#/quote/#Reply.getReplyID()#')#"><span>QUOTE</span></a>
					<cfif rc.userid IS Reply.getUser_ID()>
						<a class="button" href="#event.buildLink('forums.editReply/#rc.Topic.getTopicID()#/edit/#Reply.getReplyID()#')#"><span>EDIT</span></a>
					</cfif>
				</span>
				<div class="clear-all"><br /></div>
			</div>
			<div class="clear-all"><br /></div>
		</div>
		
		<div class="clear-all"><br /></div>
		<br />
	</cfloop>
	
	#rc.Paging.renderit(rc.count, event.buildLink('forums.replies/#rc.Topic.getTopicID()#/#rc.Topic.getTitle()#/page/@page@') )#
	<hr>
	
	<cfset rc.quickEdit = true />
	#renderView(view='forums/editreply')# 

	<div class="clear-all"><br /></div>
	

</cfoutput>