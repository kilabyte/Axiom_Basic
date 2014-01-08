
#import <Foundation/Foundation.h>

#import "UpdateItem.h"

@interface XMLUpdater : NSObject <NSXMLParserDelegate>{

@private        
    UpdateItem*			_currentRSSItem;
    NSMutableString*	_contentOfCurrentRSSItemProperty;
	NSMutableArray*		_results;
}

@property (nonatomic, retain)  UpdateItem* currentRSSItem;
@property (nonatomic, retain) NSMutableString* contentOfCurrentRSSItemProperty;
@property (nonatomic, retain) NSMutableArray* results;

- (void)parseXMLFileAtURL:(NSURL *)URL;
- (void)addToRSSItemsList:(UpdateItem *)newRSSItem;

@end
