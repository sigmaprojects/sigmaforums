component persistent="true" accessors="true" table="forum_replies" {

	property name="replyid" ormtype="integer"	fieldtype="id" generator="native" generated="insert";
	property name="created" ormtype="timestamp"	notnull="true";
	property name="updated" ormtype="timestamp"	notnull="true";
	property name="content" ormtype="clob"		notnull="true" type="string" required="true";   
	
	// Rating Plugin Property
	property name="rateIndex" formula="select sum(forum_ratings.rateIndex) from forum_ratings where forum_ratings.replyid = replyid";

	
	property name="topic" fieldtype="many-to-one" fkcolumn="topicid" cfc="SigmaForums.model.forums.Topic.Topic" missingRowIgnored="false" inverse="true";
	property name="topic_id" column="topicid" insert="false" update="false";
	
	property name="user" persistent="true" fieldtype="many-to-one" cfc="solitary.model.users.User" fkcolumn="user_id" fetch="join" notnull="true" cascade="all";
	property name="user_id" column="user_id" insert="false" update="false";
	
	property name="user_InformationService"	inject="entityService:User_Information" persistent="false";
	public any function getUserInformation() {
		return user_InformationService.get(THIS.getUser().getUserID());
	}

	public string function getFormattedContent() {
		var str = THIS.getContent();
		var lEntities = "&##xE7;,&##xF4;,&##xE2;,&Icirc;,&Ccedil;,&Egrave;,&Oacute;,&Ecirc;,&OElig,&Acirc;,&laquo;,&raquo;,&Agrave;,&Eacute;,&le;,&yacute;,&chi;,&sum;,&prime;,&yuml;,&sim;,&beta;,&lceil;,&ntilde;,&szlig;,&bdquo;,&acute;,&middot;,&ndash;,&sigmaf;,&reg;,&dagger;,&oplus;,&otilde;,&eta;,&rceil;,&oacute;,&shy;,&gt;,&phi;,&ang;,&rlm;,&alpha;,&cap;,&darr;,&upsilon;,&image;,&sup3;,&rho;,&eacute;,&sup1;,&lt;,&cent;,&cedil;,&pi;,&sup;,&divide;,&fnof;,&iquest;,&ecirc;,&ensp;,&empty;,&forall;,&emsp;,&gamma;,&iexcl;,&oslash;,&not;,&agrave;,&eth;,&alefsym;,&ordm;,&psi;,&otimes;,&delta;,&ouml;,&deg;,&cong;,&ordf;,&lsaquo;,&clubs;,&acirc;,&ograve;,&iuml;,&diams;,&aelig;,&and;,&loz;,&egrave;,&frac34;,&amp;,&nsub;,&nu;,&ldquo;,&isin;,&ccedil;,&circ;,&copy;,&aacute;,&sect;,&mdash;,&euml;,&kappa;,&notin;,&lfloor;,&ge;,&igrave;,&harr;,&lowast;,&ocirc;,&infin;,&brvbar;,&int;,&macr;,&frac12;,&curren;,&asymp;,&lambda;,&frasl;,&lsquo;,&hellip;,&oelig;,&pound;,&hearts;,&minus;,&atilde;,&epsilon;,&nabla;,&exist;,&auml;,&mu;,&frac14;,&nbsp;,&equiv;,&bull;,&larr;,&laquo;,&oline;,&or;,&euro;,&micro;,&ne;,&cup;,&aring;,&iota;,&iacute;,&perp;,&para;,&rarr;,&raquo;,&ucirc;,&omicron;,&sbquo;,&thetasym;,&ni;,&part;,&rdquo;,&weierp;,&permil;,&sup2;,&sigma;,&sdot;,&scaron;,&yen;,&xi;,&plusmn;,&real;,&thorn;,&rang;,&ugrave;,&radic;,&zwj;,&there4;,&uarr;,&times;,&thinsp;,&theta;,&rfloor;,&sub;,&supe;,&uuml;,&rsquo;,&zeta;,&trade;,&icirc;,&piv;,&zwnj;,&lang;,&tilde;,&uacute;,&uml;,&prop;,&upsih;,&omega;,&crarr;,&tau;,&sube;,&rsaquo;,&prod;,&quot;,&lrm;,&spades;";
		var lEntitiesChars = "�,�,�,�,�,�,�,�,�,�,�,�,�,�,?,�,?,?,?,�,?,?,?,�,�,�,�,�,�,?,�,�,?,�,?,?,�,�,>,?,?,?,?,?,?,?,?,�,?,�,�,<,�,�,?,?,�,�,�,�,?,?,?,?,?,�,�,�,�,�,?,�,?,?,?,�,�,?,�,�,?,�,�,�,?,�,?,?,�,�,&,?,?,�,?,�,�,�,�,�,�,�,?,?,?,?,�,?,?,�,?,�,?,�,�,�,?,?,?,�,�,�,�,?,?,�,?,?,?,�,?,�, ,?,�,?,�,?,?,�,�,?,?,�,?,�,?,�,?,�,�,?,�,?,?,?,�,?,�,�,?,?,�,�,?,�,?,�,?,�,?,?,?,?,�,?,?,?,?,?,�,�,?,�,�,?,?,?,�,�,�,?,?,?,?,?,?,�,?,"",?,?";
		return ReplaceList(str, lEntities, lEntitiesChars);
	}



}