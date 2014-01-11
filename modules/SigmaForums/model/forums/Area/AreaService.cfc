component extends="coldbox.system.orm.hibernate.VirtualEntityService" singleton {
	
	public AreaService function init(){
		super.init(entityName="Area");
		return this;
	}

	public void function addView(required Area){
		Arguments.Area.setViews( Arguments.Area.getViews()+1 );
		super.save(Arguments.Area);
	}

}