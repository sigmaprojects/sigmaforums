component extends="coldbox.system.Interceptor" output="false" hint="" {

	public void function configure() {
		
	}


	public void function htmlTitle(required Event, required interceptData) {
		/*
		// Use the private request collection for data not directly relevant to the visitor
		var prc = event.getCollection( private = true );
		//	Construct application registry if the cached version expired
		if (!getColdboxOCM().lookup('registry'))
			getColdboxOCM().set('registry', getModel('ApplicationService').generateRegistry(), getSetting('CacheApplicationTime'));
		
		// Provide reference to registry
		prc.registry = getColdboxOCM().get('registry');
		
		// Construct keyword reference if the cached version expired
		if (!getColdBoxOCM().lookup('keywords'))
			getColdboxOCM().set('keywords', getModel('BlogService').fetchKeywords(), getSetting('CacheApplicationTime'));
		
		prc.keywords = getColdboxOCM().get('keywords');
		
		// Construct top keywords reference if the cached version expired 
		if (!getColdBoxOCM().lookup('top_keywords') OR !getColdBoxOCM().lookup('top_keywords_list')) {
			var kws = getModel('BlogService').fetchKeywords(sortByQuantity=true,max=getSetting('MaxTopKeywords'));
			var i = 0;
			var topkw = [];
			for (i=1; i <= arrayLen(kws); i++)
				arrayAppend(topkw, kws[i].getKeyword());
			getColdboxOCM().set('top_keywords', arrayToList(topkw, ', ') , getSetting('RSSFeedCacheTime'));
		}
		prc.topKeywords = getColdboxOCM().get('top_keywords');
		*/

		switch( arguments.interceptData.event ) {
			case 'SigmaForums:forums.index': {
				
				break;
			}
			case 'SigmaForums:forums.topics': {
				/*
				writedump(arguments);
				abort;
				*/
				event.setValue('title', arguments.interceptData.Section.getTitle() );
			}
			break;
			case 'SigmaForums:forums.replies': {
				writedump(arguments);
				abort;
			}
			break; 
		}

	}

}
