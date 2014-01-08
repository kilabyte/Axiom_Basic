
#import "WeatherSearch.h"

static NSUInteger parsedRSSItemsCounter;

@implementation WeatherSearch

@synthesize currentRSSItem = _currentRSSItem;
@synthesize contentOfCurrentRSSItemProperty = _contentOfCurrentRSSItemProperty;
@synthesize results = _results;
@synthesize isParsing;
@synthesize parser;

// Limit the number of parsed RSSItems to 25 Otherwise the application runs very slowly on the device.
#define MAX_RSSITEMS 5

- (id)init {
	if (self = [super init]) {
		_results = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
}

-(void)parseXMLFileAtURL:(NSURL *)URL{
//	_results = [ [NSMutableArray alloc] init];
	[_results removeAllObjects];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
	parsedRSSItemsCounter = 0;
	

    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
	
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    isParsing = YES;
    [parser parse];
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (qName) {
        elementName = qName;
    }
    

	
    if ([elementName isEqualToString:@"forecast_information"]) {
        
        self.contentOfCurrentRSSItemProperty = nil;
        parsedRSSItemsCounter++;
		SearchItem *p = [[SearchItem alloc] init];
		self.currentRSSItem = p;
		[self addToRSSItemsList:p];

        
	} else if ([elementName isEqualToString:@"city"]) {
		
        // Create a mutable string to hold the contents of the 'georss:point' element.
        // The contents are collected in parser:foundCharacters:.
        self.contentOfCurrentRSSItemProperty = [NSMutableString string];
		if (gotCodeID == NO) {
			weatherCode = [attributeDict valueForKey:@"data"];
           self.currentRSSItem.locationID = [attributeDict valueForKey:@"data"];
			gotCodeID = YES;
		}

		
    } else {
        // The element isn't one that we care about, so set the property that holds the 
        // character content of the current element to nil. That way, in the parser:foundCharacters:
        // callback, the string that the parser reports will be ignored.
        self.contentOfCurrentRSSItemProperty = nil;
    }
    
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{     
	if (qName) {
		elementName = qName;
	}	
}

-(void)stopParsing{	
	[parser abortParsing];
}

- (void)addToRSSItemsList:(SearchItem *)newRSSItem
{
	[_results addObject:newRSSItem];
}

- (void)parser:(NSXMLParser *)parserF foundCharacters:(NSString *)string
{
	if (parsedRSSItemsCounter == MAX_RSSITEMS) {
		
		isParsing = NO;
		gotCodeID = NO;
		[parserF abortParsing];
		return;
    }
	
	//NSLog(@"foundCharacters >>>>>>>>>>>>>>>>>> %@ ", string);
    if (self.contentOfCurrentRSSItemProperty) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
		[self.contentOfCurrentRSSItemProperty appendString:string];
//		self.contentOfCurrentRSSItemProperty = nil;
    }
}

- (void)dealloc {
	[parser release];
	parser = nil;
	[_currentRSSItem release];
	[_contentOfCurrentRSSItemProperty release];
	[_results release];
	[super dealloc];
}


@end
