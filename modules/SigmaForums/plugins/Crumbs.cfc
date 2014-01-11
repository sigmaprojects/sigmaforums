<!---
	pretty much a copy of Luis's paging plugin
	thought of moving this to a context decorator
	but a plugin seems more suitable
--->
<cfcomponent name="Crumbs" 
			 hint="A Breadcrumbs plugin" 
			 extends="coldbox.system.plugin" 
			 output="false" 
			 cache="true">
  
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->	

    <cffunction name="init" access="public" returntype="Crumbs" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
  		super.Init(arguments.controller);
  		setpluginName("Crumbs");
  		setpluginVersion("1.0");
  		setpluginDescription("Breadcrumbs plugin");

  		//Return instance
  		return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->	
	
	<!--- render crumbs --->
	<cffunction name="renderit" access="public" returntype="any" hint="render plugin crumbs" output="false" >
		<cfset var event = getController().getRequestService().getContext() />
		<cfset var rc = event.getCollection() />
		<cfset var crumbs = "" />
		<!--- uh, i know there's a better way to do this, but lets just walk it for now --->
		<cfoutput>
		<cfsavecontent variable="crumbs">
			<ul id="crumbs">
				<li><a href="#event.buildLink('forums')#">Home</a></li>

				<cfif rc.event is 'SigmaForums:forums.topics'>
					<li><a href="#event.buildLink('forums.sections/#rc.section.getArea().getAreaID()#/#rc.section.getArea().getTitle()#')#">#rc.section.getArea().getTitle()#</a></li>
					<li>#rc.section.getTitle()#</li>
				</cfif>

				<cfif rc.event is 'SigmaForums:forums.replies'>
					<li><a href="#event.buildLink('forums.sections/#rc.topic.getSection().getArea().getAreaID()#/#rc.topic.getSection().getArea().getTitle()#')#">#rc.topic.getSection().getArea().getTitle()#</a></li>
					<li><a href="#event.buildLink('forums.topics/#rc.topic.getSection().getSectionID()#/#rc.topic.getSection().getTitle()#')#">#rc.topic.getSection().getTitle()#</a></li>
					<li>#rc.topic.getTitle()#</li>
				</cfif>

			</ul>
			
		</cfsavecontent>
		</cfoutput>

		<cfreturn crumbs />
	</cffunction>


</cfcomponent>