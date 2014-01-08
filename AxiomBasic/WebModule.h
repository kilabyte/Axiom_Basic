//
//  WebModule.h
//  SilosMedia
//
//  Created by Dave Sferra on 10-10-09.
//  Copyright 2010 Blue Hawk Solutions inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class WebView;

@interface WebModule : NSView <NSTextFieldDelegate>{
	
	IBOutlet NSTextField *urlBar;
	IBOutlet WebView *_webView;
	BOOL didLoad;
	IBOutlet NSProgressIndicator *loadingInd;

}

-(IBAction)loadStringURL:(id)sender;
-(void)loadPageWithURL:(NSString*)url;
@end
