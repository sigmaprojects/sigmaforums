<cfoutput>
	
<cfif structKeyExists(rc,'quotedReply')>
	<cfset rc.content = '<blockquote><cite>Quote: #rc.quotedReply.getUser().getName()#</cite><hr>#rc.quotedReply.getFormattedContent()#</blockquote> <br />' & event.getValue('content','') />
</cfif>

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


	<h6>Creating / Editing Reply in #rc.Topic.getTitle()#<strong></strong></h6>

	<div class="form">
		<cfform name="editTopic" action="#event.BuildLink('forums.saveReply')#">
			<cfif IsNumeric(rc.Reply.getReplyID())>
				<input name="replyID" type="hidden" value="#rc.Reply.getReplyID()#" />
			</cfif>
			<input type="hidden" name="TopicID" value="#rc.Topic.getTopicID()#">

			<ol>
				<cfif structKeyExists(rc,'quickedit')>
					<textarea name="content" id="content">#event.getValue('content','')#</textarea>
				<cfelse>
				<li>
					<!---
						welllll i thought about this, but i dunno how this would work on Ralio or whatever else
						<cftextarea richtext="true" name="content" id="content" skin="office2003" value="#event.getValue('content','')#" />
					--->
					<textarea name="content" id="content" class="rte">#event.getValue('content','')#</textarea>
				</li>
				</cfif>
				<li>
					<input type="submit" class="submit" value="Post" />
					<div class="clr"></div>
				</li>
			</ol>
	
		</cfform>
	</div>



</cfoutput>