component extends="coldbox.system.orm.hibernate.VirtualEntityService" singleton {
	
	
	public RatingService function init(replyService="" inject="model:replyService@SigmaForums"){
		variables.replyService = arguments.replyService;
		super.init(entityName="Rating");
		return this;
	}


	public void function Rate(required string ReplyID, required string UserID, required numeric RateIndex) {
		if( Arguments.ReplyID != '0'
			&& Arguments.UserID != '0'
			&& IsNumeric(Arguments.RateIndex)
			&& Arguments.RateIndex NEQ 0
			&& Arguments.RateIndex GTE -1 
			&& Arguments.RateIndex LTE 1 ) {
			// Maybe wrap this whole thing around a if target_userid != userid, so users cant rate their own replies
			// obviously some abuse without it, people could new reply/rate/delete reply over and over 
			var CompositeKey = {
				replyid	= Trim(Arguments.ReplyID),
				userid	= Trim(Arguments.UserID)
			};
			
			if( isNull(EntityLoadByPK('Rating',CompositeKey)) ) {
				var Rating = super.New('Rating', Arguments);
			} else {
				var Rating = EntityLoadByPK('Rating',CompositeKey);
				Rating.setRateIndex( Arguments.RateIndex );
			}
			
			var Reply = replyService.get( Arguments.ReplyID );
			
			Rating.setTarget_UserID( Reply.getUser_ID() );
			
			super.Save(Rating);
		}
	}
	
	public numeric function getRateIndexSum(required string ReplyID) {
		var Params = {
			replyid = Arguments.ReplyID
		};
		var q = ORMExecuteQuery("select sum(rateIndex) from Rating where replyid=:replyid", Arguments );
		if(!IsNull(q) and IsArray(q) and ArrayLen(q) GTE 1) {
			return q[1];
		} else {
			return 0;
		}
	}

}