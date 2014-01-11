component persistent="true" table="forum_areas" {

	property name="areaid" ormtype="integer" fieldtype="id" generator="native" generated="insert";
	property name="created" ormtype="timestamp" notnull="true";
	property name="updated" ormtype="timestamp" notnull="true";
	property name="title" type="string" required="true" notnull="true";
	property name="views" type="numeric" default="0";

	property name="sections" singularName="section" type="array" fieldtype="one-to-many" cfc="SigmaForums.model.forums.Section.Section" fkcolumn="areaid" inverse="true" cascade="all-delete-orphan" orderby="created desc";
	

	public Area function init() {
		return This;
	}

	
}