
#import "XMLWeather.h"
#import "AxiomAppDelegate.h"

static NSUInteger parsedRSSItemsCounter;

@implementation XMLWeather

@synthesize currentRSSItem = _currentRSSItem;
@synthesize contentOfCurrentRSSItemProperty = _contentOfCurrentRSSItemProperty;
@synthesize results = _results;
@synthesize isParsing;
@synthesize parser,_currentCondition,day2Icon;;

// Limit the number of parsed RSSItems to 25 Otherwise the application runs very slowly on the device.
#define MAX_RSSITEMS 6

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
    if ([elementName isEqualToString:@"current_condition"]
		|| [elementName isEqualToString:@"weather"]) {
        
        self.contentOfCurrentRSSItemProperty = nil;
        parsedRSSItemsCounter++;
        
		// An entry in the RSS feed represents an earthquake, so create an instance of it.
		WeatherItem *p = [[WeatherItem alloc] init];
		self.currentRSSItem = p;
		[self addToRSSItemsList:p];

        
	} else if ([elementName isEqualToString:@"observation_time"]
               || [elementName isEqualToString:@"weatherDesc"]
               || [elementName isEqualToString:@"temp_F"]
			   || [elementName isEqualToString:@"tempMaxF"]
               || [elementName isEqualToString:@"weatherIconUrl"]) {
    
        self.contentOfCurrentRSSItemProperty = [NSMutableString string];
		
    } else {
        self.contentOfCurrentRSSItemProperty = nil;
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{     
	if (qName) {
		elementName = qName;
	}
	
	NSString *s = [self.contentOfCurrentRSSItemProperty stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[self.contentOfCurrentRSSItemProperty setString:s];
    
    
    if ([elementName isEqualToString:@"observation_time"]) {
        self.currentRSSItem.lastUpdate = [NSString stringWithString:self.contentOfCurrentRSSItemProperty];
        
    }
    else if ([elementName isEqualToString:@"weatherDesc"]) {
        //current condition Text (cloudy)
        if (weHaveCurrent == NO) {
            self.currentRSSItem.conditionCurrent = [NSString stringWithString:self.contentOfCurrentRSSItemProperty];
            weHaveCurrent = YES;
        }
    }
    else if ([elementName isEqualToString:@"temp_F"]) {
        //gets the current tempurature in C
        self.currentRSSItem.temp_c_data = [NSString stringWithString:self.contentOfCurrentRSSItemProperty];
        
    }
    else if ([elementName isEqualToString:@"tempMaxF"]) {
        //four day forecast
        NSLog(@"%@",elementName);
        static int i = 0;
        if (i == 0){
            self.currentRSSItem.dayForecast1 = [NSString stringWithString:self.contentOfCurrentRSSItemProperty];
        }
        else if (i == 1){
            self.currentRSSItem.dayForecast2 = [NSString stringWithString:self.contentOfCurrentRSSItemProperty];
        }
        else if (i == 2){
            self.currentRSSItem.dayForecast3 = [NSString stringWithString:self.contentOfCurrentRSSItemProperty];
        }
        else if (i == 3){
            self.currentRSSItem.dayForecast4 = [NSString stringWithString:self.contentOfCurrentRSSItemProperty];
        }

        i++;
        if (i>3) {
            i=0;
        }
        
    }
    else if ([elementName isEqualToString:@"weatherIconUrl"]) {
        //four day forecast icons with current condtion icon
        static int d = 0;
        if (d == 0){
            self.currentRSSItem.iconNumber = [NSString stringWithString:self.contentOfCurrentRSSItemProperty];
        }
        else if (d == 1){
            self.currentRSSItem.dayIcon1 = [NSString stringWithString:self.contentOfCurrentRSSItemProperty];
        }
        else if (d == 2){
            self.currentRSSItem.dayIcon2 = [NSString stringWithString:self.contentOfCurrentRSSItemProperty];
        }
        else if (d == 3){
            self.currentRSSItem.dayIcon3 = [NSString stringWithString:self.contentOfCurrentRSSItemProperty];
        }
        else if (d == 4){
            self.currentRSSItem.dayIcon4 = [NSString stringWithString:self.contentOfCurrentRSSItemProperty];
        }
        
        d++;
        if (d>4) {
            d=0;
        }
		
    } else {
        // The element isn't one that we care about, so set the property that holds the
        // character content of the current element to nil. That way, in the parser:foundCharacters:
        // callback, the string that the parser reports will be ignored.
        self.contentOfCurrentRSSItemProperty = nil;
    }

    
}

-(void)stopParsing{
	[parser abortParsing];
}

- (void)addToRSSItemsList:(WeatherItem *)newRSSItem
{
	[_results addObject:newRSSItem];
}

- (void)parser:(NSXMLParser *)parserF foundCharacters:(NSString *)string
{
	if (parsedRSSItemsCounter == MAX_RSSITEMS) {
		
		isParsing = NO;
		weHaveCurrent = NO;
		weHaveCurrentIcon = NO;
		weHaveDay2 = NO;
		weHaveDay2T = NO;
		weHaveDay3T = NO;
		weHaveDay4T = NO;
		weHaveDay5T = NO;
		[parserF abortParsing];
		return;
    }
	

//	NSLog(@"foundCharacters >>>>>>>>>>>>>>>>>> %@ ", string);
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
