component extends="coldbox.system.orm.hibernate.VirtualEntityService" singleton {
	
	public User_InformationService function init(
		userService="" inject="model:userService@solitary"
	){
		super.init(entityName="User_Information");
		variables.userService = arguments.userService;
		return this;
	}

	public void function createDefaultIfNull(required UserID) {
		if( !super.Exists( arguments.UserID ) ) {
			var User_Information = super.new();
			var User = userService.get(arguments.userID);
			User_Information.setUser(User);
			super.Save(User_Information);
		}
	} 

}