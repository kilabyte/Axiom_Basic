//
//  UpdateManager.m
//  SilosMedia
//
//  Created by Dave Sferra on 10-09-13.
//  Copyright 2010 Blue Hawk Solutions inc. All rights reserved.
//

#import "UpdateManager.h"
#import "ZipArchive.h"

#define XMLUpdateManagerURL @"http://update.bluehawksolutions.com/softwareupdate.xml"

@implementation UpdateManager
@synthesize updateArray;
@synthesize hasInternetAccess;
@synthesize downloadedData;
@synthesize filePath;
@synthesize downloading, downloadProgress, downloadIsIndeterminate;
@synthesize isChecking;

- (id)initWithSoftwareUpdate
{
	self = [super init];
	if (self != nil) {
		
	}
	return self;
}

-(void)viewWillDraw{
	if (isChecking == NO) {
		[self start];
		isChecking = YES;
	}
	
}



-(void)viewDidHide{
	isChecking = NO;
}


-(void)start{
	[status setStringValue:@"Checking for updates..."];
	[progressIn setHidden:NO];
	[progressIn setIndeterminate:YES];
	[installButton setHidden:YES];
	[progressIn startAnimation:self];
	[self performSelector:@selector(beginParse:) withObject:nil afterDelay:1.5];
}

-(IBAction)beginParse:(id)sender{
	appDelegate = [[AxiomAppDelegate alloc] init];
	if ([AxiomAppDelegate isDataSourceAvailable]) {
		updateArray = [[NSMutableArray alloc] init];
		NSLog(@"URL received, begin XML parse");
		
		updateParser = [[XMLUpdater alloc] init];
		[updateParser parseXMLFileAtURL:[NSURL URLWithString:XMLUpdateManagerURL]];
		NSLog(@"Parse completed. Begin parse extraction");
		for(int i = 0 ; i < [updateParser.results count] ; i++){
			UpdateItem* item = [updateParser.results objectAtIndex:i];
			if( ([item.titleEnt compare:@""] == NSOrderedSame )) {//&& ([item.publishDate compare:@""] == NSOrderedSame) ) {
				[updateParser.results removeObjectAtIndex:i];
			}

		}
		
		NSLog(@"Extraction completed. Begin reloading data");
		
		updateArray = updateParser.results;
		NSLog(@"Results Updater - %@",updateArray);
		[self compareUpdate];
		
	}
	else {
		[status setStringValue:@"You are not connected to the internet."];
		
	}

}

-(BOOL)isUpdateAvaliable{
	appDelegate = [[AxiomAppDelegate alloc] init];
	if ([AxiomAppDelegate isDataSourceAvailable]) {
		updateArray = [[NSMutableArray alloc] init];
		NSLog(@"URL received, begin XML parse");
		
		updateParser = [[XMLUpdater alloc] init];
		[updateParser parseXMLFileAtURL:[NSURL URLWithString:XMLUpdateManagerURL]];
		NSLog(@"Parse completed. Begin parse extraction");
		for(int i = 0 ; i < [updateParser.results count] ; i++){
			UpdateItem* item = [updateParser.results objectAtIndex:i];
			if( ([item.titleEnt compare:@""] == NSOrderedSame )) {//&& ([item.publishDate compare:@""] == NSOrderedSame) ) {
				[updateParser.results removeObjectAtIndex:i];
			}
			
		}
		
		NSLog(@"Extraction completed. Begin reloading data");
		
		updateArray = updateParser.results;
		NSLog(@"Results Updater - %@",updateArray);
		
		UpdateItem *item = [updateArray objectAtIndex:0];
		[nameOf setStringValue:[NSString stringWithFormat:@"Name: %@",item.titleEnt]];
		[versionOf setStringValue:[NSString stringWithFormat:@"Version: %@",item.version]];
		identifier = item.ident;
		NSString *systemIdent = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
		float versionServer = [item.version floatValue];
		float version = [[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"] floatValue];
		
		
		if (version < versionServer && [systemIdent isEqualToString:identifier]) {
			return YES;
			
		}
		else {
			[status setStringValue:@"No updates available"];
			[installButton setHidden:YES];
			[progressIn setHidden:YES];
			[progressIn stopAnimation:nil];
			return NO;
			
		}
		
	}
	else {
		[status setStringValue:@"You are not connected to the internet. \nPlease try again later"];
		[progressIn setHidden:YES];
		return NO;
	}
	
	return NO;
}





-(void)compareUpdate{
	UpdateItem *item = [updateArray objectAtIndex:0];
	[nameOf setStringValue:[NSString stringWithFormat:@"Name: %@",item.titleEnt]];
	[versionOf setStringValue:[NSString stringWithFormat:@"Version: %@",item.version]];
	identifier = item.ident;
	NSString *systemIdent = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
	float versionServer = [item.version floatValue];
	float version = [[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"] floatValue];
	
	if (version < versionServer && [systemIdent isEqualToString:identifier]) {
		[status setStringValue:@"Update is available..."];
		if (![progressIn isIndeterminate]) {
			[progressIn setIndeterminate:YES];
			[progressIn startAnimation:nil];
		}
		//begin download
		[self performSelector:@selector(startDownload:) withObject:nil afterDelay:1];
	}
	else {
		[status setStringValue:@"No updates available"];
		[installButton setHidden:YES];
		[progressIn setHidden:YES];
		[progressIn stopAnimation:nil];
		

	}


	
	
}


- (IBAction)startDownload:(id)sender{
	[status setStringValue:@"Downloading..."];
    assert(!download);
	userDirectory = @"~";
	userDirectory = [userDirectory stringByExpandingTildeInPath];
	NSLog(@"User Directory %@", userDirectory);
	[userDirectory retain];
	[progressIn setIndeterminate:YES];
	[progressIn startAnimation:self];
	
    UpdateItem *item = [updateArray objectAtIndex:0];
    NSString* urlString = item.downloadURL;
	NSLog(@"Download URL = %@",item.downloadURL);
    assert(urlString);
    
    urlString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([urlString length] == 0) {
        NSBeep();
        return;
    }
    
    NSURL* url = [NSURL URLWithString:urlString];
    if (!url) {
        NSBeep();
        return;
    }
    
    //originalURL = [url copy];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    self.downloadIsIndeterminate = YES;
	[progressIn setIndeterminate:self.downloadIsIndeterminate];
    self.downloadProgress = 0.0f;
    self.downloading = YES;
    
    download = [[NSURLDownload alloc] initWithRequest:request delegate:self];
}

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response;
{
    expectedContentLength = [response expectedContentLength];
    if (expectedContentLength > 0.0) {
        self.downloadIsIndeterminate = NO;
		[progressIn setIndeterminate:self.downloadIsIndeterminate];
        downloadedSoFar = 0;
    }
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(NSUInteger)length
{
	
    downloadedSoFar += length;
	//float inc = (float)length / (float)expectedContentLength;
	//[progressIn incrementBy:5];

	
    if (downloadedSoFar >= expectedContentLength) {
        // the expected content length was wrong as we downloaded more than expected
        // make the progress indeterminate
        self.downloadIsIndeterminate = YES;
		[progressIn setIndeterminate:self.downloadIsIndeterminate];
    } else {
        self.downloadProgress = (float)downloadedSoFar / (float)expectedContentLength;
		[progressIn setDoubleValue:self.downloadProgress*100];
    }
}


- (void)download:(NSURLDownload *)aDownload decideDestinationWithSuggestedFilename:(NSString *)filename
{
    NSString* path = [[@"~/" stringByExpandingTildeInPath] stringByAppendingPathComponent:filename];
    [aDownload setDestination:path allowOverwrite:YES];
	filePath = path;
}

- (void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path
{
    fileURL = [[NSURL alloc] initFileURLWithPath:path];
}

- (void)downloadDidFinish:(NSURLDownload *)download{

    [self performSelector:@selector(startInstall) withObject:nil afterDelay:2];
	NSLog(@"Download Complete");
	[status setStringValue:@"Download Complete!"];
    self.downloading = NO;
}

- (void)download:(NSURLDownload *)aDownload didFailWithError:(NSError *)error
{
    //[self presentError:error modalForWindow:[self windowForSheet] delegate:nil didPresentSelector:NULL contextInfo:NULL];
	NSLog(@"Download Failed");
	[status setStringValue:@"Download Failed. Try again later"];
	[progressIn setHidden:YES];
    self.downloading = NO;
}





-(void)startInstall{
    // Override point for customization after application launch.
	[status setStringValue:@"Begin instalation..."];
	[progressIn setIndeterminate:YES];
	// Unzip
	NSDictionary            *error = nil;
    NSString                *script = nil;
	NSString				*script2 = nil;
    NSAppleEventDescriptor  *res = nil;

	script = [NSString stringWithFormat:@"tell application \"Terminal\" \nactivate \ndo script \"unzip -o \%@\" \nend tell",filePath];
	script2 = [NSString stringWithFormat:@"tell application \"Terminal\" \nquit \nend tell"];
	NSLog(@"Script to update %@",script);
    res = [self runWithSource:script andReturnError:&error];

	res = [self runWithSource:script2 andReturnError:&error];
	
	
	[status setStringValue:@"File extracted..."];
	[self performSelector:@selector(copyToApplications) withObject:nil afterDelay:1.0];

}

-(void)copyToApplications{
	[progressIn startAnimation:self];
	[status setStringValue:@"Installing..."];
	
	NSString *completePath = [NSString stringWithFormat:@"%@/",userDirectory];
	NSLog(@"Got the Directory %@",completePath);
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	NSString *f = [NSString stringWithFormat:@"%@/README.rtf",completePath];
	NSString *m = [NSString stringWithFormat:@"%@/AxiomBasic.app",completePath];
	NSString *u = [NSString stringWithFormat:@"%@/Updater.app",completePath];
	
	NSString *source, *sourceM, *sourceU, *destination1, *destination2, *destination3, *path;
	
	source = f;
	sourceM = m;
	sourceU = u;
	destination1 = @"/Applications/README.rtf";
	destination2 = @"/Applications/AxiomBasic.app";
	destination3 = @"/Applications/Updater.app";
	path = @"/Applications/";
	
	if ([fileManager fileExistsAtPath:destination2]) {
		NSLog(@"Found Existing Build");
		[fileManager removeItemAtPath:destination1 error:nil];
		[fileManager removeItemAtPath:destination2 error:nil];
		[fileManager removeItemAtPath:destination3 error:nil];
	}
	
	
	if ([fileManager fileExistsAtPath:sourceM]) 
	{
		NSLog(@"Installing new build");
		[fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
		[fileManager copyItemAtPath:sourceU toPath:[NSString stringWithFormat:@"%@Updater.app",path] error:nil];
		[fileManager copyItemAtPath:source toPath:[NSString stringWithFormat:@"%@README.rtf",path] error:nil];
		[fileManager copyItemAtPath:sourceM toPath:[NSString stringWithFormat:@"%@AxiomBasic.app",path] error:nil];
	}

	[self performSelector:@selector(finishInstall) withObject:nil afterDelay:1.5];
	[fileManager autorelease];
}

-(void)finishInstall{
	[status setStringValue:@"Cleaning up..."];
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	if ([fileManager fileExistsAtPath:filePath]) {
		[fileManager removeItemAtPath:filePath error:nil];
		[fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/__MACOSX/",userDirectory] error:nil];
		[fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/",userDirectory] error:nil];
		NSLog(@"Cleaned up files!");
	}
	
	[status setStringValue:@"Finished!, Restarting Axiom. Please Wait."];
	[progressIn stopAnimation:self];
	[progressIn setHidden:YES];
	[self performSelector:@selector(runFinishScript) withObject:nil afterDelay:2];
	[fileManager autorelease];
}

-(void)runFinishScript{
	NSBundle *bundle = [NSBundle bundleWithPath:@"/Applications/AxiomBasic.app"]; // or updater app
	NSString *path = [bundle executablePath];
	NSTask *task = [[NSTask alloc] init];
	
	[task setLaunchPath:path];
	[task launch];
	
	[task release];
	task = nil;
	
	if (path == nil) {
		//error
		[status setStringValue:@"There was an error, please manually restart"];
	}
	else {
		[NSApp terminate:nil];
	}


}



#pragma mark AppleScript Utilities
- (NSAppleEventDescriptor *) runWithSource: (id) source andReturnError: (NSDictionary **) error {
    NSAppleScript           *script = nil;
    
    // [NSString class] == NSString unlike NSCFString of an instance...
    if ([source class] == [@"" class]) {
        script = [[[NSAppleScript alloc] initWithSource:source] autorelease];
    } else {
        script = source;
    }
    NSAppleEventDescriptor  *res = [script executeAndReturnError:error];
    
    return(res);
}

@end
