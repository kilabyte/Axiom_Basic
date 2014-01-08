//
//  SettingsManager.m
//  SilosMedia
//
//  Created by Dave Sferra on 10-12-20.
//  Copyright 2010 Blue Hawk Solutions inc. All rights reserved.
//

#import "SettingsManager.h"
#import "SearchItem.h"

@implementation SettingsManager




-(void)viewWillDraw{
	if (isChecking == NO) {
		isChecking = YES;
		[version setStringValue:[NSString stringWithFormat:@"Axiom Basic V%@",[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"]]];
		
		if (a.postalCode != nil) {
			[postalCodeF setStringValue:a.postalCode];
		}
		else {
			NSLog(@"No location set");
            [postalCodeF setStringValue:@""];
		}
		
		if (a.weatherCity != nil) {
			[locationText setStringValue:a.weatherCity];
		}
		else {
			[locationText setStringValue:@"No location set"];
		}
        a = AppDelegate;
        [a setActivationState];
		
		if (a.activated) {
			[licenseType setStringValue:@"Activated"];
		}
		else {
			[licenseType setStringValue:@"Trial"];
		}
        
        if([a.isCelcius isEqualToString:@"yes"]){
            [isCelciusButton setState:NSOnState];
        }
        else {
            [isCelciusButton setState:NSOffState];
        }
	}
}

-(IBAction)toggleisCelcius:(id)sender{
    a = AppDelegate;
    if(isCelciusButton.state == NSOnState){
        a.isCelcius = @"yes";
    }
    else {
        a.isCelcius = @"no";
    }
}

-(void)startParse{
	if ([AxiomAppDelegate isDataSourceAvailable]) {
		[self getLocationID];
		
		weatherArray = [[NSMutableArray alloc] init];
		weatherParser = [[XMLWeather alloc] init];
		if (a.postalCode == nil) {
			NSLog(@"Axiom - Location is not set in settings");
			[locationText setStringValue:@"Error - Try again"];
			
			return;
		}
		
        NSString *myURL = [NSString stringWithFormat:@"http://www.google.com/ig/api?weather=%@",location];
        NSString *fixedURL = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)myURL, NULL, NULL, kCFStringEncodingUTF8);
        NSURL *URL = [NSURL URLWithString:fixedURL];
        [fixedURL release];
		[weatherParser parseXMLFileAtURL:URL];	
		[locationText setStringValue:@"Loading data..."];

		weatherArray = weatherParser.results;
		//NSLog(@"Results Weather - %@",weatherParser.results);
		
		[self performSelector:@selector(displayInfo)];
		
	}
	else {
		//proide error on why we can't parse
		NSLog(@"Axiom - User is not connected to internet");
		[locationText setStringValue:@"You are not connected to the internet."];
	}
}
-(void)getLocationID{
	if ([AxiomAppDelegate isDataSourceAvailable]) {
		
        if ([a.weatherCity isEqualToString:@""]) {
            [locationText setStringValue:@"No location set"];
            return;
        }
		//get Core Location here...
		//get the search weather code here
		
		NSString *s = [NSString stringWithFormat:@"http://www.google.com/ig/api?weather=%@",a.postalCode];
		searchArray = [[NSMutableArray alloc] init];
		searchParser = [[WeatherSearch alloc] init];
		//NSLog(@"Search Address = %@",s);
		if (a.postalCode == nil) {
			NSLog(@"Axiom - Location is not set in settings");
			[locationText setStringValue:@"Error - Try again"];
			
			return;
		}
		
		[searchParser parseXMLFileAtURL:[NSURL URLWithString:s]];
		searchArray = searchParser.results;
		//NSLog(@"Results Weather - %@",searchParser.results);
		
		//set the location to the ivar
		if ([searchArray count] > 0) {
			SearchItem *i = [searchArray objectAtIndex:0];
			location = i.locationID;
		}
		else {
			[locationText setStringValue:@"Could not find your city."];
			
		}
		
		
		
	}
	else {
		//proide error on why we can't parse
		NSLog(@"Axiom - User is not connected to internet");
		[locationText setStringValue:@"You are not connected to the internet."];
	}
	
}

-(void)displayInfo{
	if ([weatherArray count] > 0) {
		[locationText setStringValue:a.weatherCity];
	}
	else {
		[locationText setStringValue:@"Location not found"];
	}

	

	[_progress stopAnimation:nil];
}


-(void)viewDidHide{
	isChecking = NO;

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[postalCodeF stringValue] forKey:@"SavedLocation"];
	a.postalCode = [postalCodeF stringValue];
	[defaults synchronize];
    

    /*//trim white space
    NSString *s = [postalCodeF stringValue];
    a.weatherCity = [postalCodeF stringValue];
    a.postalCode = [s stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	NSLog(@"%@",s);
	[a.postalCode retain];
    [a retain];
	[locationText setStringValue:@"Checking location..."];
	[self performSelector:@selector(startParse)];*/
}



- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
	[_progress startAnimation:nil];

    //trim white space
    NSString *s = [postalCodeF stringValue];
    a.weatherCity = [postalCodeF stringValue];
    a.postalCode = [s stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	NSLog(@"%@",s);
	[a.postalCode retain];
    [a retain];
	[locationText setStringValue:@"Checking location..."];
	[self performSelector:@selector(startParse)];
	return YES;	
}



@end
