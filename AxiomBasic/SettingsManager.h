//
//  SettingsManager.h
//  SilosMedia
//
//  Created by Dave Sferra on 10-12-20.
//  Copyright 2010 Blue Hawk Solutions inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AxiomAppDelegate.h"
#import "XMLWeather.h"
#import "WeatherSearch.h"

@interface SettingsManager : NSView <NSTextFieldDelegate>{
	BOOL isChecking;
	AxiomAppDelegate *a;
	IBOutlet NSTextField *postalCodeF;
	IBOutlet NSProgressIndicator *_progress;
	IBOutlet NSTextField *locationText;
	NSMutableArray *weatherArray;
	XMLWeather *weatherParser;
	WeatherSearch *searchParser;
	NSMutableArray *searchArray;
	IBOutlet NSTextField *version;
	IBOutlet NSTextField *licenseType;
	NSString *location;
    IBOutlet NSButton *isCelciusButton;
}

-(IBAction)toggleisCelcius:(id)sender;
-(void)getLocationID;

@end
