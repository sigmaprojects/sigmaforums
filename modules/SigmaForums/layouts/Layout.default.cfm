<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
<cfoutput>
	<title>Sigma Forums V .2 - #event.getValue('title','')#</title>
</cfoutput>
<meta name="keywords" content="" />
<meta name="description" content="" />

	<cfset addAsset(event.getModuleRoot() & "/includes/styles/default.css") />
	<cfset addAsset(event.getModuleRoot() & "/includes/styles/Paging.css") />
	<cfset addAsset(event.getModuleRoot() & "/includes/styles/crumbs.css") />
	<cfset addAsset(event.getModuleRoot() & "/includes/javascript/jquery-1.5.2.min.js") />
	
	

</head>
<body>

<div id="outer">


	<div id="header">
		<div id="headercontent">
			<h1>Zenlike<sup>1.0</sup></h1>
			<h2>A free design by NodeThirtyThree ---</h2>
		</div>
	</div>


	<form method="post" action="search.cfm">
		<div id="search">
			<input type="text" class="text" maxlength="64" name="keywords" />
			<input type="submit" class="submit" value="Search" />
		</div>
	</form>


	<div id="headerpic"></div>
		
		<div id="menu">
		<!-- HINT: Set the class of any menu link below to "active" to make it appear active -->
		<cfoutput>
		<ul>
			<li id="Home">
				<a href="#event.buildLink('forums')#" class="active">
					<img src="#event.getModuleRoot()#/includes/images/icons/16-image.png" />Home
				</a>
			</li>
			<li id="Help">
				<a href="##">
					<img src="#event.getModuleRoot()#/includes/images/icons/16-file-page.png" /><del>Help</del>
				</a>
			</li>
			<li id="Controls">
				<a href="#event.buildLink('forums.users.editProfile')#">
					<img src="#event.getModuleRoot()#/includes/images/icons/16-member.png" />Controls
				</a>
			</li>
			<li id="Search">
				<a href="##">
					<img src="#event.getModuleRoot()#/includes/images/icons/16-zoom.png" /><del>Search</del>
				</a>
			</li>
		</ul>
		<span>
			<a href="##">
				<img src="#event.getModuleRoot()#/includes/images/icons/16-member-add.png" /><del>SignUp</del>
			</a>
			<a href="#event.BuildLink('security.login')#">
				<img src="#event.getModuleRoot()#/includes/images/icons/16-security-key.png" />Login
			</a>
			<cfif ! IsSimpleValue(getPlugin('SessionStorage').getVar('user',''))>
				<a href="#event.BuildLink('security.logout')#">
					<img src="#event.getModuleRoot()#/includes/images/icons/16-security-lock-open.png" />Logout
				</a>
			</cfif>
		</span>
		</cfoutput>
	</div>
	<div id="menubottom"></div>

	
	<div id="content">

		<!-- Normal content: Stuff that's not going to be put in the left or right column. -->
		<div id="normalcontent">
			<div class="contentarea">
				
				<cfset WriteOutput(getPlugin("messageBox").renderit(true)) />
				<cfoutput>#renderView()#</cfoutput>

				
			</div>
		</div>

	</div>

	<div class="clear-all"><br /></div>
	<br />
	<div class="clear-all"><br /></div>
	<br />

	<div id="footer">
			<div class="left">&copy; 2006 Your Website Name. All rights reserved.</div>
			<div class="right">Design by <a href="http://www.nodethirtythree.com/">NodeThirtyThree Design</a></div>
	</div>
	
</div>

</body>
</html>