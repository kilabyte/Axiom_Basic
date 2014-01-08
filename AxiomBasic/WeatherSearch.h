
#import <Foundation/Foundation.h>

#import "SearchItem.h"

@interface WeatherSearch : NSObject <NSXMLParserDelegate>{

	
    SearchItem*			_currentRSSItem;
    NSMutableString*	_contentOfCurrentRSSItemProperty;
	NSMutableArray*		_results;
	NSXMLParser *parser;
	BOOL isParsing;
	NSString *weatherCode;
	BOOL gotCodeID;
}

@property (nonatomic, retain)  SearchItem* currentRSSItem;
@property (nonatomic, retain) NSMutableString* contentOfCurrentRSSItemProperty;
@property (nonatomic, retain) NSMutableArray* results;
@property(nonatomic, assign) BOOL isParsing;
@property (nonatomic,retain) NSXMLParser *parser;


-(void)stopParsing;
- (void)parseXMLFileAtURL:(NSURL *)URL;
- (void)addToRSSItemsList:(SearchItem *)newRSSItem;

@end
