//
//  VolumeManager.m
//  SilosMedia
//
//  Created by Dave Sferra on 10-12-20.
//  Copyright 2010 Blue Hawk Solutions inc. All rights reserved.
//

#import "VolumeManager.h"


@implementation VolumeManager

-(void)viewWillDraw{
	if (isChecking == NO) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		volumeLevel = [defaults integerForKey:@"VolumeLevel"];
		
		AxiomAppDelegate *d = AppDelegate;
		
		NSInteger i;
		i = d.iTunes.soundVolume/10;
		volumeLevel = i;
		[self turnOnBarsWithBarNumber:i];
		isChecking = YES;
	}
}



-(void)viewDidHide{
	isChecking = NO;
}


-(IBAction)volumeUp:(id)sender{
	volumeLevel++;
	if (volumeLevel >10) {
		volumeLevel = 10;
	}
	
	
	AxiomAppDelegate *d = AppDelegate;
	d.iTunes.soundVolume = (volumeLevel*10);
	[self turnOnBarsWithBarNumber:volumeLevel];
}


-(IBAction)volumeDown:(id)sender{
	volumeLevel--;
	if (volumeLevel <0) {
		volumeLevel = 0;
	}
	
	AxiomAppDelegate *d = AppDelegate;
	d.iTunes.soundVolume = (volumeLevel*10);
	[self turnOnBarsWithBarNumber:volumeLevel];
}


-(void)turnOnBarsWithBarNumber:(NSInteger)barNumber{
	
	if (barNumber == 0) {
		vBar1.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar2.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar3.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar4.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar5.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar6.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar7.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar8.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar9.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar10.image = [NSImage imageNamed:@"volumeBar.png"];
	}
	
	if (barNumber == 1) {
		vBar1.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar2.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar3.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar4.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar5.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar6.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar7.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar8.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar9.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar10.image = [NSImage imageNamed:@"volumeBar.png"];
	}
	
	if (barNumber == 2) {
		vBar1.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar2.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar3.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar4.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar5.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar6.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar7.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar8.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar9.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar10.image = [NSImage imageNamed:@"volumeBar.png"];
	}
	
	if (barNumber == 3) {
		vBar1.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar2.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar3.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar4.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar5.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar6.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar7.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar8.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar9.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar10.image = [NSImage imageNamed:@"volumeBar.png"];
	}
	
	if (barNumber == 4) {
		vBar1.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar2.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar3.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar4.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar5.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar6.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar7.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar8.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar9.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar10.image = [NSImage imageNamed:@"volumeBar.png"];
	}
	
	if (barNumber == 5) {
		vBar1.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar2.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar3.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar4.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar5.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar6.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar7.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar8.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar9.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar10.image = [NSImage imageNamed:@"volumeBar.png"];
	}
	
	if (barNumber == 6) {
		vBar1.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar2.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar3.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar4.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar5.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar6.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar7.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar8.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar9.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar10.image = [NSImage imageNamed:@"volumeBar.png"];
	}
	
	if (barNumber == 7) {
		vBar1.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar2.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar3.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar4.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar5.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar6.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar7.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar8.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar9.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar10.image = [NSImage imageNamed:@"volumeBar.png"];
	}
	
	if (barNumber == 8) {
		vBar1.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar2.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar3.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar4.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar5.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar6.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar7.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar8.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar9.image = [NSImage imageNamed:@"volumeBar.png"];
		vBar10.image = [NSImage imageNamed:@"volumeBar.png"];
	}
	
	if (barNumber == 9) {
		vBar1.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar2.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar3.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar4.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar5.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar6.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar7.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar8.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar9.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar10.image = [NSImage imageNamed:@"volumeBar.png"];
	}
	
	if (barNumber == 10) {
		vBar1.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar2.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar3.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar4.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar5.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar6.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar7.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar8.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar9.image = [NSImage imageNamed:@"volumeBar2.png"];
		vBar10.image = [NSImage imageNamed:@"volumeBar2.png"];
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:volumeLevel forKey:@"VolumeLevel"];
	[defaults synchronize];
	
}


@end
