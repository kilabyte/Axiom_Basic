
#import <Foundation/Foundation.h>

#import "WeatherItem.h"

@interface XMLWeather : NSObject <NSXMLParserDelegate>{
 
@private
    WeatherItem*			_currentRSSItem;
    NSMutableString*	_contentOfCurrentRSSItemProperty;
	NSMutableArray*		_results;
	NSXMLParser *parser;
	BOOL isParsing;
	BOOL weHaveCurrent;
	BOOL weHaveCurrentIcon;
	BOOL gotDay;
	NSString *_day1;
	NSString *_day2;
	NSString *_day3;
	NSString *_day4;
	NSString *_day5;
	NSString *_currentCondition;
	
	BOOL weHaveDay2;
	BOOL weHaveDay2T;
	
	BOOL weHaveDay3;
	BOOL weHaveDay3T;
	
	BOOL weHaveDay4;
	BOOL weHaveDay4T;
	
	BOOL weHaveDay5;
	BOOL weHaveDay5T;
	
	
	NSString *day2Icon;//not needed
}

@property (nonatomic, retain)  WeatherItem* currentRSSItem;
@property (nonatomic, retain) NSMutableString* contentOfCurrentRSSItemProperty;
@property (nonatomic, retain) NSMutableArray* results;
@property(nonatomic, assign) BOOL isParsing;
@property (nonatomic,retain) NSXMLParser *parser;
@property (nonatomic,retain)NSString *_currentCondition;
@property(nonatomic, retain)	NSString *day2Icon;

-(void)stopParsing;
- (void)parseXMLFileAtURL:(NSURL *)URL;
- (void)addToRSSItemsList:(WeatherItem *)newRSSItem;

@end
