//
//  WebModule.m
//  SilosMedia
//
//  Created by Dave Sferra on 10-10-09.
//  Copyright 2010 Blue Hawk Solutions inc. All rights reserved.
//

#import "WebModule.h"
#import <dispatch/dispatch.h>

@implementation WebModule

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}


-(void)viewWillDraw{
	if (didLoad == NO && self.isHidden == NO) {
		[self loadPageWithURL:@"http://bluehawksolutions.com"];
        [urlBar setEditable:YES];
        [urlBar setEnabled:YES];
		didLoad = YES;
	}
	
}

-(IBAction)loadStringURL:(id)sender{
	NSString *qString = [NSString stringWithFormat:@"%@",[urlBar stringValue]];
	NSRange r = [qString rangeOfString:@"http://"];
	if (r.location == NSNotFound){
		qString = [NSString stringWithFormat:@"http://%@",qString];
	}
	
	
	if (![[urlBar stringValue] isEqualToString:qString]) {
		[[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:qString]]];
		[urlBar setStringValue:qString];
		NSLog(@"URL = %@",qString);
	}

}

-(void)loadPageWithURL:(NSString*)url{
	[[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
	NSLog(@"URL = %@",url);
    [[urlBar window] makeFirstResponder:urlBar];
}


- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame{
	[loadingInd setHidden:NO];
	[loadingInd startAnimation:self];
}
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
	[loadingInd stopAnimation:self];
	[loadingInd setHidden:YES];

}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame{
	[loadingInd stopAnimation:self];
	[loadingInd setHidden:YES];
	[urlBar setStringValue:@"Error. Try again"];

}
- (void)textDidEndEditing:(NSNotification *)aNotification{
    [[urlBar window] makeFirstResponder:urlBar];
}


-(void)viewDidHide{
    NSLog(@"test");
}

@end
