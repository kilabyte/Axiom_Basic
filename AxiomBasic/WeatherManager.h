//
//  WeatherManager.h
//  SilosMedia
//
//  Created by Dave Sferra on 10-10-31.
//  Copyright 2010 Blue Hawk Solutions inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XMLWeather.h"
#import "AxiomAppDelegate.h"
#import "WeatherItem.h"
#import "WeatherSearch.h"
#import "SearchItem.h"
#import <CoreLocation/CoreLocation.h>

@interface WeatherManager : NSView <CLLocationManagerDelegate>{
	BOOL isChecking;
	
	XMLWeather *weatherParser;
	WeatherSearch *searchParser;
	NSMutableArray *weatherArray;
	NSMutableArray *searchArray;
	AxiomAppDelegate *appDelegate;
	CLLocationManager *locationManager;
    __block NSString *geoCity;
    __block NSString *geoProv;
    CLLocation *currentLocation;
	NSString *location;
	BOOL isLoadingData;
    
	IBOutlet NSTextField *_mainTitle;
	IBOutlet NSImageView *_currentImage;
	IBOutlet NSTextField *_currentCon;
	IBOutlet NSTextField *_currentTemp;
	IBOutlet NSTextField *_lastUpdate;
	IBOutlet NSProgressIndicator *_loadingBar;
	IBOutlet NSProgressIndicator *_loadingBar2;
	
	IBOutlet NSTextField *_day1;
	IBOutlet NSTextField *_day2;
	IBOutlet NSTextField *_day3;
	IBOutlet NSTextField *_day4;
	
	IBOutlet NSImageView *_day1Icon;
	IBOutlet NSImageView *_day2Icon;
	IBOutlet NSImageView *_day3Icon;
	IBOutlet NSImageView *_day4Icon;
	
	IBOutlet NSTextField *_day1High;
	IBOutlet NSTextField *_day2High;
	IBOutlet NSTextField *_day3High;
	IBOutlet NSTextField *_day4High;
	
	IBOutlet NSTextField *_day1Low;
	IBOutlet NSTextField *_day2Low;
	IBOutlet NSTextField *_day3Low;
	IBOutlet NSTextField *_day4Low;
	
	
	
	
	

}

@property(retain)CLLocationManager *locationManager;

-(NSData *)getImageFromUrl:(NSString*)imageUrl;
-(void)start;

@end
