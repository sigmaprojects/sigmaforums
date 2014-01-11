component extends="coldbox.system.orm.hibernate.VirtualEntityService" singleton {
	
	public SectionService function init(){
		super.init(entityName="Section");
		return this;
	}

	public void function addView(required Section){
		Arguments.Section.setViews( Arguments.Section.getViews()+1 );
		super.save(Arguments.Section);
	}


}