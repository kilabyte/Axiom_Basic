//
//  VolumeManager.h
//  SilosMedia
//
//  Created by Dave Sferra on 10-12-20.
//  Copyright 2010 Blue Hawk Solutions inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AxiomAppDelegate.h"

@interface VolumeManager : NSView {
	IBOutlet NSImageView *vBar1;
		IBOutlet NSImageView *vBar2;
		IBOutlet NSImageView *vBar3;
		IBOutlet NSImageView *vBar4;
		IBOutlet NSImageView *vBar5;
		IBOutlet NSImageView *vBar6;
		IBOutlet NSImageView *vBar7;
		IBOutlet NSImageView *vBar8;
		IBOutlet NSImageView *vBar9;
		IBOutlet NSImageView *vBar10;
	
	IBOutlet NSButton *downButton;
	IBOutlet NSButton *upButton;
	
	BOOL isChecking;
	NSInteger volumeLevel;

}

-(IBAction)volumeUp:(id)sender;
-(IBAction)volumeDown:(id)sender;
-(void)turnOnBarsWithBarNumber:(NSInteger)barNumber;

@end
