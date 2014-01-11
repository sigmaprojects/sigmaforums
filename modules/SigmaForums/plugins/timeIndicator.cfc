/*
Author      :	Don Quist
Date        :	04/19/2011
License		: 	Apache 2 License
Description :	Time Indicator thing
*/
component name="timeIndicator" hint="A time indicator plugin" extends="coldbox.system.plugin" output="false" cache="true" {
	
	/*------------------------------------------- CONSTRUCTOR -------------------------------------------*/
	public timeIndicator function init(required controller) {
  		super.Init(arguments.controller);
  		setpluginName("timeIndicator");
  		setpluginVersion("1.0");
  		setpluginDescription("A  time indicator plugin");
		
  		//Return instance
  		return this;
	}


	/*------------------------------------------- PUBLIC -------------------------------------------*/
	public string function getIcon(any time=Now()) {
		var times = {
			ThreeNineM_Start=CreateTime(3,00,00),
			ThreeNineM_END=CreateTime(8,59,59),
			NineThreeD_Start=CreateTime(9,00,00),
			ThreeNineD_End=CreateTime(14,59,59),
			ThreeNineE_Start=CreateTime(15,00,00),
			NineThreeE_End=CreateTime(20,59,59)
		};
		if( isTimeBetween(times.ThreeNineM_Start,times.ThreeNineM_END,arguments.time) ) {
			return '18-time-morning.png';
		} else if( isTimeBetween(times.NineThreeD_Start,times.ThreeNineD_End,arguments.time) ) {
			return '18-time-noon.png';
		} else if( isTimeBetween(times.ThreeNineE_Start,times.NineThreeE_End,arguments.time) ) {
			return '18-time-evening.png';
		} else {
			return '18-time-night.png';
		}
		return '18-time-night.png'; //if all else fails somehow
	}

	/*------------------------------------------- PRIVATE -------------------------------------------*/
	private boolean function isTimeBetween(required date minTime,required date maxTime, date time=Now()) {
		var current = createTime(timeFormat(arguments.time,"H"),timeFormat(arguments.time,"mm"),timeFormat(arguments.time,"ss"));
		if(dateDiff("n",arguments.minTime,current) gt 0 and dateDiff("n",arguments.maxTime,current) lt 0) {
			return true;
		} else {
			return false;
		}
	}
}