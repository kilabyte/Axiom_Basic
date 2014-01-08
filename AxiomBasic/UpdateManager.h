//
//  UpdateManager.h
//  SilosMedia
//
//  Created by Dave Sferra on 10-09-13.
//  Copyright 2010 Blue Hawk Solutions inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XMLUpdater.h"
#import "AxiomAppDelegate.h"
#import "UpdateItem.h"

@class AxiomAppDelegate;

@interface UpdateManager : NSView <NSURLDownloadDelegate>{

	XMLUpdater *updateParser;
	NSMutableArray *updateArray;
	AxiomAppDelegate *appDelegate;
	BOOL hasInternetAccess;
	
	IBOutlet NSTextField *status;
	IBOutlet NSButton *installButton;
	IBOutlet NSProgressIndicator *progressIn;
	IBOutlet NSTextField *nameOf;
	IBOutlet NSTextField *versionOf;
	NSString *identifier;
	BOOL isChecking;

	
	NSString *directoryPath;
	NSString *filePath;
	NSFileHandle *file;
	NSURLConnection *con;
	NSMutableData *downloadedData;
	NSInteger *receivedLength;
	
	BOOL downloading;
    float downloadProgress;
    long long expectedContentLength;
    long long downloadedSoFar;
    BOOL downloadIsIndeterminate;
    
    NSURLDownload* download;
    NSURL* originalURL;
    NSURL* fileURL;
	
	NSString *userDirectory;
}

@property(nonatomic,retain)NSString *filePath;
@property(nonatomic,retain)NSMutableData *downloadedData;
@property(nonatomic,retain)NSMutableArray *updateArray;
@property (nonatomic,assign) BOOL hasInternetAccess;
@property(nonatomic,assign)BOOL isChecking;
@property(getter=isDownloading, setter=setDownloading:) BOOL downloading;
@property float downloadProgress;
@property BOOL downloadIsIndeterminate;


-(BOOL)isUpdateAvaliable;
- (id)initWithSoftwareUpdate;
-(IBAction)beginParse:(id)sender;
-(void)compareUpdate;
- (IBAction)startDownload:(id)sender;
-(void)start;
- (NSAppleEventDescriptor *) runWithSource: (id) source andReturnError: (NSDictionary **) error;
@end
