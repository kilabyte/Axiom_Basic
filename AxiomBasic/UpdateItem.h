

#import <Foundation/Foundation.h>

@interface UpdateItem : NSObject {

@private

    NSString*	_title;           // Holds Title of RSS Item.
	NSString* _version;
	NSString* _downloadURL;
	NSString* _versionType;
	NSString* _ident;
}

@property (nonatomic, retain) NSString* titleEnt;
@property (nonatomic, retain) NSString* version;
@property (nonatomic, retain) NSString* ident;
@property (nonatomic, retain) NSString* downloadURL;
@property (nonatomic, retain) NSString* versionType;
@end

