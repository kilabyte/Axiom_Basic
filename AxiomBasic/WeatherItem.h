

#import <Foundation/Foundation.h>

@interface WeatherItem : NSObject {

@private
	
    NSString* _cityName;
	NSString* _lastUpdate;
	NSString* _conditionDataCurrent;
	NSString* _iconNumber;
	NSString* _temp_c_data;
	NSString* _highC;
	NSString* _lowC;
	
	NSString* _dayForecast1;
	NSString* _dayIcon1;
	NSString* _dayForecast2;
	NSString* _dayIcon2;
	NSString* _dayForecast3;
	NSString* _dayIcon3;
	NSString* _dayForecast4;
	NSString* _dayIcon4;
}

@property(nonatomic,retain)NSString* cityName;
@property(nonatomic,retain)NSString* lastUpdate;
@property(nonatomic,retain)NSString* conditionCurrent;
@property(nonatomic,retain)NSString* iconNumber;
@property(nonatomic,retain)NSString* temp_c_data;
@property(nonatomic,retain)NSString* highC;
@property(nonatomic,retain)NSString* lowC;

@property(nonatomic,retain)NSString* dayForecast1;
@property(nonatomic,retain)NSString* dayIcon1;
@property(nonatomic,retain)NSString* dayForecast2;
@property(nonatomic,retain)NSString* dayIcon2;
@property(nonatomic,retain)NSString* dayForecast3;
@property(nonatomic,retain)NSString* dayIcon3;
@property(nonatomic,retain)NSString* dayForecast4;
@property(nonatomic,retain)NSString* dayIcon4;
@end

