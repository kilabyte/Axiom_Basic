//
//  WeatherManager.m
//  SilosMedia
//
//  Created by Dave Sferra on 10-10-31.
//  Copyright 2010 Blue Hawk Solutions inc. All rights reserved.
//

#import "WeatherManager.h"
#import <dispatch/dispatch.h>
#import "AxiomAppDelegate.h"

@implementation WeatherManager
@synthesize locationManager;

-(void)viewWillDraw{
	if (isChecking == NO && [AppDelegate isShowingWeatherView] == YES) {
        isChecking = YES;
		[_loadingBar startAnimation:nil];
		[_loadingBar2 startAnimation:nil];
		[_mainTitle setStringValue:@"Getting weather conditions..."];
		[self performSelector:@selector(start)];
		
	}
	
}

-(void)viewDidHide{
	isChecking = NO;
    isLoadingData = NO;
    [weatherArray removeAllObjects];
    [locationManager release];
}


-(void)start{
	appDelegate = AppDelegate;
	if ([appDelegate hasInternet] && isChecking != NO) {
        if (!self.locationManager) {
            self.locationManager = [[CLLocationManager alloc] init];
            [self.locationManager setDelegate:self];
            [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
            [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
            [self.locationManager startUpdatingLocation];
        }
  }
	else {
			//proide error on why we can't parse
			NSLog(@"Axiom - User is not connected to internet");
			[_mainTitle setStringValue:@"You are not connected to the internet."];
		}
}

-(void)displayInfo{
	NSLog(@"Axiom - Populating Weather...");
	WeatherItem *item = [[WeatherItem alloc] init];
	//object at index 0 is the forecast information
	//object at index 1 is the current conditions
    //object at index 2 is the 4 day forecast

	//set up the current forecast
	[_currentImage setHidden:NO];
	[_currentCon setHidden:NO];
	[_currentTemp setHidden:NO];
	[_lastUpdate setHidden:NO];
	[_day1  setHidden:NO];
	[_day2  setHidden:NO];
	[_day3  setHidden:NO];
	[_day4  setHidden:NO];
	[_day1Icon  setHidden:NO];
	[_day2Icon  setHidden:NO];
	[_day3Icon  setHidden:NO];
	[_day4Icon  setHidden:NO];
	[_day1High  setHidden:NO];
	[_day2High  setHidden:NO];
	[_day3High  setHidden:NO];
	[_day4High  setHidden:NO];
	
	//set up the days of the week
	int daysToAdd = 1;
	NSDate *now = [NSDate date];
	
	NSDate *now2 = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
	NSString * weekday2 = [now2 descriptionWithCalendarFormat:@"%A" timeZone:nil
													  locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
	[_day1 setStringValue:weekday2];
	
	NSDate *now3 = [now dateByAddingTimeInterval:60*60*24*(daysToAdd+1)];
	NSString * weekday3 = [now3 descriptionWithCalendarFormat:@"%A" timeZone:nil
													  locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
	[_day2 setStringValue:weekday3];
	
	NSDate *now4 = [now dateByAddingTimeInterval:60*60*24*(daysToAdd+2)];
	NSString * weekday4 = [now4 descriptionWithCalendarFormat:@"%A" timeZone:nil
													  locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
	[_day3 setStringValue:weekday4];
	
	NSDate *now5 = [now dateByAddingTimeInterval:60*60*24*(daysToAdd+3)];
	NSString * weekday5 = [now5 descriptionWithCalendarFormat:@"%A" timeZone:nil
													   locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
	[_day4 setStringValue:weekday5];
	
    if ([weatherArray count] < 1) {
        NSLog(@"Axiom - Weather error, city error");
        [_loadingBar stopAnimation:nil];
        [_loadingBar2 stopAnimation:nil];
        [_mainTitle setStringValue:@"Error - We could not get data for your current location"];
        return;
    }
    NSString *tempur = [NSString stringWithFormat:@"%@",[appDelegate.isCelcius isEqualToString:@"yes"]?@"°C":@"°F"];
    //current information
	item = [weatherArray objectAtIndex:0];
	[_lastUpdate setStringValue:[NSString stringWithFormat:@"Last Update: %@",item.lastUpdate]];
	[_currentCon setStringValue:item.conditionCurrent];
    if ([appDelegate.isCelcius isEqualToString:@"yes"]) {
        float temp = [item.temp_c_data floatValue];
        float calc = ((temp-32)*5)/9;
        item.temp_c_data = [NSString stringWithFormat:@"%.0f",calc];
    }
	[_currentTemp setStringValue:[NSString stringWithFormat:@"%@ %@",item.temp_c_data,tempur]];

	NSImage *image = [[NSImage alloc] initWithData:[self getImageFromUrl:item.iconNumber]];
    [_currentImage setImage:image];
    [image release];
	
    
    
	//get and display the 3 day forcast from the delegate
	item = [weatherArray objectAtIndex:1];
    NSImage *image1 = [[NSImage alloc] initWithData:[self getImageFromUrl:item.dayIcon1]];
    [_day1Icon setImage:image1];
    if ([appDelegate.isCelcius isEqualToString:@"yes"]) {
        float temp = [item.dayForecast1 floatValue];
        float calc = ((temp-32)*5)/9;
        item.dayForecast1 = [NSString stringWithFormat:@"%.0f",calc];
    } 
    [_day1High setStringValue:[NSString stringWithFormat:@"%@ %@",item.dayForecast1, tempur]];
    [image1 release];
    
    item = [weatherArray objectAtIndex:2];
    NSImage *image2 = [[NSImage alloc] initWithData:[self getImageFromUrl:item.dayIcon2]];
    [_day2Icon setImage:image2];
    if ([appDelegate.isCelcius isEqualToString:@"yes"]) {
        float temp = [item.dayForecast2 floatValue];
        float calc = ((temp-32)*5)/9;
        item.dayForecast2 = [NSString stringWithFormat:@"%.0f",calc];
    } 
    [_day2High setStringValue:[NSString stringWithFormat:@"%@ %@",item.dayForecast2, tempur]];
    [image2 release];
    
    item = [weatherArray objectAtIndex:3];
    NSImage *image3 = [[NSImage alloc] initWithData:[self getImageFromUrl:item.dayIcon3]];
    [_day3Icon setImage:image3];
    if ([appDelegate.isCelcius isEqualToString:@"yes"]) {
        float temp = [item.dayForecast3 floatValue];
        float calc = ((temp-32)*5)/9;
        item.dayForecast3 = [NSString stringWithFormat:@"%.0f",calc];
    } 
    [_day3High setStringValue:[NSString stringWithFormat:@"%@ %@",item.dayForecast3, tempur]];
    [image3 release];
    
    //had to mimic item 3 as weather is n/a for item 4
    item = [weatherArray objectAtIndex:2];
    NSImage *image4 = [[NSImage alloc] initWithData:[self getImageFromUrl:item.dayIcon2]];
    [_day4Icon setImage:image4];
    if ([appDelegate.isCelcius isEqualToString:@"yes"]) {
        double temper = [item.dayForecast2 doubleValue];
        double calc = ((temper-32)*5)/9;
        item.dayForecast2 = [NSString stringWithFormat:@"%.0f",calc];
    } 
    [_day4High setStringValue:[NSString stringWithFormat:@"%@ %@",item.dayForecast2, tempur]];
    [image4 release];
	
	[_loadingBar2 stopAnimation:nil];
    [_loadingBar stopAnimation:nil];
	NSLog(@"Axiom - Populating Weather...DONE");
    [weatherArray removeAllObjects];
}
-(NSData *)getImageFromUrl:(NSString*)imageUrl{
    //get image from url to load
    NSURL *imageURL = [NSURL URLWithString:imageUrl];
	NSData *imageData;
	imageData = [NSData dataWithContentsOfURL:imageURL];
    return imageData;
}


//Start geo location for weather
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	// Ignore updates where nothing we care about changed
	if (newLocation.coordinate.longitude == oldLocation.coordinate.longitude &&
		newLocation.coordinate.latitude == oldLocation.coordinate.latitude &&
		newLocation.horizontalAccuracy == oldLocation.horizontalAccuracy)
	{
        NSLog(@"Did Not Change");
		return;
	}

    if (isLoadingData == NO) {
        isLoadingData = YES;
        currentLocation = newLocation;
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
#ifdef DEBUG
            NSLog(@"%@ %@ %@ %@ %@ %@ %@ %@", placemark.country, placemark.ISOcountryCode, placemark.postalCode, placemark.administrativeArea, placemark.locality, placemark.subLocality, placemark.thoroughfare, placemark.subThoroughfare);
#endif
            [_mainTitle setStringValue:[NSString stringWithFormat:@"%@, %@",placemark.locality,placemark.administrativeArea]];
            if ([placemark.country isEqualToString:@"Canada"]) {
                appDelegate.isCelcius = @"yes";
            }
            
        }];
        weatherArray = [[NSMutableArray alloc] init];
        weatherParser = [[XMLWeather alloc] init];
        
        NSString *lat = nil;
        NSString *lng = nil;
        lat = [NSString stringWithFormat:@"%+.6f", newLocation.coordinate.latitude];
        lng = [NSString stringWithFormat:@"%+.6f", newLocation.coordinate.longitude];
        NSString *myURL = [NSString stringWithFormat:@"http://free.worldweatheronline.com/feed/weather.ashx?q=%@,%@&format=xml&num_of_days=5&key=8182c04162202138121408",lat,lng];
        NSString *fixedURL = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)myURL, NULL, NULL, kCFStringEncodingUTF8);
        NSURL *URL = [NSURL URLWithString:fixedURL];
        [fixedURL release];
        
        [weatherParser parseXMLFileAtURL:URL];
        weatherArray = weatherParser.results;
        NSLog(@"%@",weatherArray);
        [self performSelector:@selector(displayInfo) withObject:nil afterDelay:3.0];
        [locationManager stopUpdatingLocation];
    }


}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error for geolocation");
    [_mainTitle setStringValue:@"Error loading geolocation data..."];
    [_loadingBar stopAnimation:nil];
    [_loadingBar2 stopAnimation:nil];
}



@end
