component extends="coldbox.system.orm.hibernate.EventHandler"{


	public void function postNew(any entity ) {
		SUPER.postNew(arguments.entity);
	}

	public void function preLoad(any entity ) {
		SUPER.preLoad(arguments.entity);
	}

	public void function postLoad(any entity ) {
		SUPER.postLoad(arguments.entity);
	}

	public void function preInsert(any entity ) {
		if (structKeyExists(entity, "setcreated")){
			if( ! IsDate( entity.getCreated() ) ) {
				entity.setCreated( now() );
			}
		}

		if (structKeyExists(entity, "setupdated")){
			entity.setupdated( now() );
		}
		SUPER.preInsert(arguments.entity);
	}

	public void function postInsert(any entity ) {
		SUPER.postInsert(arguments.entity);
	}

	public void function preUpdate( any entity, Struct oldData ) {
		if (structKeyExists(entity, "setupdated")){
			entity.setupdated( now() );
		}
		SUPER.preUpdate(arguments.entity, arguments.oldData);
	}

	public void function postUpdate(any entity ) {
		SUPER.postUpdate(arguments.entity);
	}

	public void function preDelete(any entity ) {
		SUPER.preDelete(arguments.entity);
	}

	public void function postDelete(any entity ) {
		SUPER.postDelete(arguments.entity);
	}


}
