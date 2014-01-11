/**
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/16/2007
Description :
	This is the Application.cfc for usage withing the ColdBox Framework.
	Make sure that it extends the coldbox object:
	coldbox.system.Coldbox
	
	So if you have refactored your framework, make sure it extends coldbox.
 
@output false
@extends coldbox.system.Coldbox
*/
component {

	// Application properties
	this.name = "Sigma_Forums";
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan(0,0,30,0);
	this.setClientCookies = true;
	this.applicationtimeout = createtimespan(0,0,0,1);

	// Mappings Imports
	this.mappings["/coldbox"] = expandPath('../coldbox');
	this.mappings["/model"] = COLDBOX_APP_ROOT_PATH & "/model";
	this.mappings["/SigmaForums"] = COLDBOX_APP_ROOT_PATH & "/modules/sigmaforums";
	this.mappings['/solitary'] = COLDBOX_APP_ROOT_PATH & "/modules/solitary";
	import coldbox.system.*;

	this.skipCFCWithError = true; 
	this.ormenabled = "true";
	this.datasource = "sigmaforums";
	this.ormsettings = {
		skipCFCWithError = true,
		autorebuild="true",
		dialect="MySQLwithMyISAM",
		dbcreate="update",
		logSQL = true,
		flushAtRequestEnd = false,
		eventHandling = true,
		eventHandler = "modules.SigmaForums.model.utilities.ORMEventHandler"
	};

	
	// ColdBox Specifics
	COLDBOX_APP_ROOT_PATH = getDirectoryFromPath(getCurrentTemplatePath());
	COLDBOX_CONFIG_FILE = "";
	COLDBOX_APP_KEY = "";


	public boolean function onApplicationStart() output=false {
		//Load ColdBox
		loadColdBox();
		return true;
	}
	
	
	public boolean function onRequestStart(String targetPage){
		if(structKeyExists(url,"ormreload")) {
			ORMReload();
		}
		reloadChecks();
		if(findNoCase('index.cfm', listLast(arguments.targetPage, '/'))) {
			processColdBoxRequest();
		}
		return true;
		
	}
	public boolean function onRequestEnd() {
		ORMFlush();
		return true;
	}
	
	public void function onSessionStart() output=false{
		
	}
	
	public void function onSessionEnd(struct sessionScope, struct appScope) output=false{
		
	}
	
}