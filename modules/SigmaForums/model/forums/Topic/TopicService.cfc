component extends="coldbox.system.orm.hibernate.VirtualEntityService" singleton {
	
	public TopicService function init(){
		super.init(entityName="Topic");
		return this;
	}

	public void function addView(required Topic){
		Arguments.Topic.setViews( Arguments.Topic.getViews()+1 );
		super.save(Arguments.Topic);
	}

}