
#import "XMLUpdater.h"

static NSUInteger parsedRSSItemsCounter;

@implementation XMLUpdater

@synthesize currentRSSItem = _currentRSSItem;
@synthesize contentOfCurrentRSSItemProperty = _contentOfCurrentRSSItemProperty;
@synthesize results = _results;


// Limit the number of parsed RSSItems to 25 Otherwise the application runs very slowly on the device.
#define MAX_RSSITEMS 15

- (id)init {
	if (self = [super init]) {
		_results = [ [NSMutableArray alloc] init];
	}
	return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
}

-(void)parseXMLFileAtURL:(NSURL *)URL{
//	_results = [ [NSMutableArray alloc] init];
	[_results removeAllObjects];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
	parsedRSSItemsCounter = 0;
	

    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
	
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    
    [parser parse];
	[parser release];
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (qName) {
        elementName = qName;
    }
    
	//NSLog(@"didStartElement ================== %@ ", elementName);
	
	
	// $BEN
	// This should not be controlled in multiple places; 
	//   Should be controlled by the CALLER of the parser, 
	//   NOT by the parser itself
	/*
	 if (parsedRSSItemsCounter == MAX_RSSITEMS) {
	 
	 [parser abortParsing];
	 return;
	 }
	 */	
	
    if ([elementName isEqualToString:@"software_update"]) {
        
        self.contentOfCurrentRSSItemProperty = nil;
        parsedRSSItemsCounter++;
        
		// An entry in the RSS feed represents an earthquake, so create an instance of it.
		UpdateItem *p = [[UpdateItem alloc] init];
		self.currentRSSItem = p;
		//[_results addObject:self.currentRSSItem];
		[self addToRSSItemsList:p];
//		[self performSelector:@selector(addToRSSItemsList:) withObject:p];
		//[self performSelectorInBackground:@selector(addToRSSItemsList:) withObject:self.currentRSSItem];
        
        // Add the new Earthquake object to the application's array of earthquakes.
		// [(id)[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(addToRSSItemsList:) withObject:self.currentRSSItem waitUntilDone:NO];
        
        // $BEN
        //   Removed all unknown / currently unused properties.
        //   They are simply code bloat.
        //
        //   Also reduced code size & readability
        
	} else if ([elementName isEqualToString:@"title"]
               || [elementName isEqualToString:@"version"]
               || [elementName isEqualToString:@"downloadURL"]
			   || [elementName isEqualToString:@"bundle"]) {
		
        // Create a mutable string to hold the contents of the 'georss:point' element.
        // The contents are collected in parser:foundCharacters:.
        self.contentOfCurrentRSSItemProperty = [NSMutableString string];
		
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
	
//	self.contentOfCurrentRSSItemProperty = (NSMutableString*)[self.contentOfCurrentRSSItemProperty stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSString *s = [self.contentOfCurrentRSSItemProperty stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[self.contentOfCurrentRSSItemProperty setString:s];
	
	
	if ([elementName isEqualToString:@"title"]) {
		self.currentRSSItem.titleEnt = [NSString stringWithString:self.contentOfCurrentRSSItemProperty];
        
	} else if ([elementName isEqualToString:@"version"]) {
		self.currentRSSItem.version = [NSString stringWithString:self.contentOfCurrentRSSItemProperty];
        
	} else if ([elementName isEqualToString:@"downloadURL"]) {
		self.currentRSSItem.downloadURL = [NSString stringWithString:self.contentOfCurrentRSSItemProperty];
		
	} 
	else if ([elementName isEqualToString:@"bundle"]) {
		self.currentRSSItem.ident = [NSString stringWithString:self.contentOfCurrentRSSItemProperty];
		
	} 
	
	
}


- (void)addToRSSItemsList:(UpdateItem *)newRSSItem
{
	[_results addObject:newRSSItem];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (parsedRSSItemsCounter == MAX_RSSITEMS) {
		
		[parser abortParsing];
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
	[_currentRSSItem release];
	[_contentOfCurrentRSSItemProperty release];
	[_results release];
	[super dealloc];
}


@end
