
#import "WeatherItem.h"


@implementation WeatherItem

@synthesize cityName = _cityName;
@synthesize lastUpdate = _lastUpdate;
@synthesize conditionCurrent = _conditionDataCurrent;
@synthesize iconNumber = _iconNumber;
@synthesize temp_c_data = _temp_c_data;
@synthesize highC = _highC;
@synthesize lowC = _lowC;

@synthesize dayForecast1 = _dayForecast1;
@synthesize dayIcon1 = _dayIcon1;
@synthesize dayForecast2 = _dayForecast2;
@synthesize dayIcon2 = _dayIcon2;
@synthesize dayForecast3 = _dayForecast3;
@synthesize dayIcon3 = _dayIcon3;
@synthesize dayForecast4 = _dayForecast4;
@synthesize dayIcon4 = _dayIcon4;


-(id) init{
	if(self = [super init]){
		 _cityName = @"";
		 _lastUpdate = @"";
		 _conditionDataCurrent = @"";
		 _iconNumber = @"";
		 _temp_c_data = @"";
		 _highC = @"";
		 _lowC = @"";
		
		 _dayForecast1 = @"";
		_dayIcon1 = @"";
		_dayForecast2 = @"";
		_dayIcon2 = @"";
		_dayForecast3 = @"";
		_dayIcon3 = @"";
		_dayForecast4 = @"";
		_dayIcon4 = @"";
	}
	return self;
}

-(void)dealloc{

	[_cityName release];
	[_lastUpdate release];
	[_conditionDataCurrent release];
	[_iconNumber release];
	[_temp_c_data release];
	[_highC release];
	[_lowC release];
	
	[_dayForecast1 release];
	[_dayIcon1 release];
	[_dayForecast2 release];
	[_dayIcon2 release];
	[_dayForecast3 release];
	[_dayIcon3 release];
	[_dayForecast4 release];
	[_dayIcon4 release];
	

	
	[super dealloc];
}




@end