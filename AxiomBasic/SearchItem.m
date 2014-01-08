
#import "SearchItem.h"


@implementation SearchItem

@synthesize locationID = _locationID;



-(id) init{
	if(self = [super init]){
			_locationID = @"";

	}
	return self;
}

-(void)dealloc{

	[_locationID release];
	
	[super dealloc];
}




@end