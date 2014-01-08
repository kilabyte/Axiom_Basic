
#import "UpdateItem.h"


@implementation UpdateItem

@synthesize titleEnt = _title;
@synthesize version = _version;
@synthesize downloadURL = _downloadURL;
@synthesize versionType = _versionType;
@synthesize ident = _ident;

-(id) init{
	if(self = [super init]){
		_title = @"";
		_version = @"";
		_downloadURL = @"";
		_versionType = @"";
		_ident = @"";
	}
	return self;
}

-(void)dealloc{

	[_title release];
	[_version release];
	[_downloadURL release];
	[_versionType release];
	[_ident release];
	
	[super dealloc];
}




@end