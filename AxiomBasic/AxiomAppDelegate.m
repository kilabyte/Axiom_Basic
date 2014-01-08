//
//  AxiomAppDelegate.m
//  Silos
//

#define DISCLAIMER_TEXT @"ATTENTION! \n\nIf you are using the software product during driving or transportation, we strogly advise you to direct all your attention to driving or transportation and to observing traffic regulations and safety requirments. Especially do not try to operate, enter data into or obtain data from the software product while driving, because such presents a life hazard, and the lack of proper attention may cause death, injury or material damage."
#define INTERNET_CHECK_INTERVAL 10
#define LICENSE_INSTALL @"/usr/bin/2c5d94dd609855f43c21c46744afec3d/f17aaabc20bfe045075927934fed52d2.zip"
#define trialTime 600 //10 hours in minutes


#import "AxiomAppDelegate.h"
#import <ScriptingBridge/ScriptingBridge.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "WindowAnimations.h"
#import <Carbon/Carbon.h>
#import "BorderlessWindow.h"
#include <dispatch/dispatch.h>
#import "validatereceipt.h"
#import "BHSDialog.h"


@implementation AxiomAppDelegate

@synthesize rootView;
@synthesize window;
@synthesize iTunes;
@synthesize currentTrackIndexField;
@synthesize trackCountField;
@synthesize mainContentView, playlistArray, playlistNumber, closePL;
@synthesize menuShowing = _menuShowing;
@synthesize userAgreed = _userAgreed;
@synthesize postalCode;
@synthesize activated;
@synthesize visNumber;
@synthesize tracksArray, weatherCity, dayF1;
@synthesize isShowingWeatherView, playlistPopover, isCelcius;

#pragma mark Main App Methods
-(NSScreen *)screen{
    NSArray *screens = [NSScreen screens];
    long c = 0;
    if ([screens count] > 1) {
        c = [screens count] - 1;
    }
    return [screens objectAtIndex:0];
}

-(void)awakeFromNib{

}
-(void)applicationWillBecomeActive:(NSNotification *)aNotification{
    NSLog(@"Axiom - Is coming back to active");
    [self performSelector:@selector(checkNewMedia)];
	/*if (self.iTunes.playerState == iTunesEPlSPlaying) {
     //check for itunes media type
     //then hide if its movie or tv
     if (self.iTunes.frontmost) {
     if(self.iTunes.currentTrack.videoKind == iTunesEVdKMovie || self.iTunes.currentTrack.videoKind == iTunesEVdKTVShow || self.iTunes.currentTrack.videoKind == iTunesEVdKMusicVideo){
     NSLog(@"Axiom - Bringing Axiom Back!");
     NSString* src1 = [NSString stringWithFormat:@"tell application \"System Events\"\n set visible of process \"iTunes\" to false\n end tell"];
     
     NSAppleScript* script1 = [[NSAppleScript alloc] initWithSource:src1];
     NSDictionary* error1;
     [script1 autorelease];
     [script1 executeAndReturnError:&error1];
     }
     }
     }*/
	
}

- (void) receiveSleepNote: (NSNotification*) note
{
    NSLog(@"Axiom - Preparing for sleep mode...");
    self.iTunes.soundVolume = 0.0;
    if (self.iTunes.playerState == iTunesEPlSPlaying) {
        [self.iTunes pause];
        iTunesShouldBePlaying = NO;
    }
    
}

- (void) receiveWakeNote: (NSNotification*) note
{
    NSLog(@"Axiom - Restoring Axiom...");
    if (self.iTunes.playerState == iTunesEPlSPaused || self.iTunes.playerState == iTunesEPlSStopped) {
        [self.iTunes playpause];
        iTunesShouldBePlaying = YES;
    }
    
    [self fadeVolume:@"in"];
    
    [self performSelector:@selector(checkForInternetAccess:) withObject:nil afterDelay:30];
    [self performSelector:@selector(checkNewMedia)];
}

- (void) fileNotifications
{
    //These notifications are filed on NSWorkspace's notification center, not the default 
    // notification center. You will not receive sleep/wake notifications if you file 
    //with the default notification center.
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self 
                                                           selector: @selector(receiveSleepNote:) 
                                                               name: NSWorkspaceWillSleepNotification object: NULL];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self 
                                                           selector: @selector(receiveWakeNote:) 
                                                               name: NSWorkspaceDidWakeNotification object: NULL];
}

-(void)checkNewMedia{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = @"~/Dropbox/CarMedia/Sync Folder/";
    NSString *tunes = @"~/Music/iTunes/iTunes Media/Automatically Add to iTunes.localized/";
    NSString *tunes2 = @"~/Music/iTunes/iTunes Media/Automatically Add to iTunes/";
    NSString *drop = @"/Applications/Dropbox.app";
    tunes = [tunes stringByExpandingTildeInPath];
    tunes2 = [tunes2 stringByExpandingTildeInPath];
    path = [path stringByExpandingTildeInPath];
    if (![manager fileExistsAtPath:drop]) {
        NSLog(@"Dropbox not found");
        return;
    }
    else {
        NSLog(@"Dropbox found");
    }
    if ([manager fileExistsAtPath:path]) {
        NSLog(@"Found Sync Folder");
        
        if ([manager contentsOfDirectoryAtPath:path error:nil]) {
            NSArray *dirContents = [manager contentsOfDirectoryAtPath:path error:nil];
            NSMutableArray *dir = [[NSMutableArray alloc] initWithArray:dirContents];
            if ([dir count] > 0) {
                if ([[dir objectAtIndex:0] isEqualToString:@".DS_Store"]) {
                    [dir removeObjectAtIndex:0];
                }
            }
            
            if ([dir count] > 0) {
                NSError *error = nil;
                for (int i = 0; i < [dir count]; i++) {
                    NSString *source = [NSString stringWithFormat:@"%@/%@",path,[dir objectAtIndex:i]];
                    NSString *dest = [NSString stringWithFormat:@"%@/%@",tunes2,[dir objectAtIndex:i]];
                    if ([manager copyItemAtPath:source toPath:dest error:&error]) {
                        NSLog(@"Axiom Sync: %@",[dir objectAtIndex:i]);
                        [manager removeItemAtPath:source error:&error];
                    }
                    else {
                        NSLog(@"Axiom Sync ERROR: %@",error);
                    }
                }
            }
        }
    }
    else {
        NSLog(@"Axiom sync folder does not exist.");
        NSError *error = nil;
        if (![manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"%@",error);
        }
    }
}

-(void)playStartUpSound{
    //start up sound
    NSBundle *mainBundle;
	mainBundle = [NSBundle mainBundle];
	NSString *startupSoundPath = [mainBundle pathForResource:@"start-up" ofType:@"wav"];
	_startupPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:startupSoundPath] error:NULL];
	[_startupPlayer play];
}

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    [[NSWorkspace sharedWorkspace] hideOtherApplications];
	self.menuShowing = FALSE;
    self.userAgreed = FALSE;
    
    [menuBG setHidden:YES];
	
	//[self checkForInternetAccess:self];
	if ([checkforInternet isValid]) {
		[checkforInternet invalidate];
		checkforInternet = nil;
	}
	
    while(self.iTunes != nil && setupMusic == NO){
        //[self setupMusic:self];
        setupMusic = YES;
        NSLog(@"Axiom - Setup media...");
    }
	
	[self performSelector:@selector(fileNotifications)];
    
    [self checkForInternetAccess:nil];
    
	[table setGridColor:[NSColor whiteColor]];
	[table setDelegate:self];
	checkforInternet = [NSTimer scheduledTimerWithTimeInterval:(INTERNET_CHECK_INTERVAL*60) target:self selector:@selector(checkForInternetAccess:) userInfo:nil repeats:YES]; 
	
	
	[self performSelectorInBackground:@selector(setupScripts) withObject:nil];
	
    
    // *************************************
    // SETS THE DISCLAIMER
    // *************************************
    [disclaimerTF setStringValue:DISCLAIMER_TEXT];
    [versionText setStringValue:[NSString stringWithFormat:@"Axiom Basic V%@",[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"]]];
	
	
	//add lisence check here
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    isCelcius = [defaults stringForKey:@"IsCelcius"];
    if (isCelcius == nil) {
        isCelcius = @"no";
    }
    timesUp = [defaults boolForKey:@"TimesUp"];
    appLocked = [defaults boolForKey:@"AppLocked"];
    licenseCount = [defaults integerForKey:@"LicenseCount"];
    postalCode = [defaults stringForKey:@"LocationNameSettings"];
	weatherCity = [defaults stringForKey:@"WeatherSetCity"];
    _isFullScreen = [defaults boolForKey:@"FullScreen"];
    activated = [AxiomAppDelegate checkForReceipt];
    
#ifdef DEBUG
    timesUp = NO;
    appLocked = NO;
    licenseCount = 0;
    NSLog(@"Axiom - We are in debug mode dont check license");
#else
    if (timesUp == NO && activated == NO) {
        checkForLicenseTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(countForLicenseTime) userInfo:nil repeats:YES];
        NSLog(@"Axiom - License Timer Started!!");
    }
    
    if (!activated) {
        [self checkForLicense];
    }
#endif
    
    if(appLocked) {
        [initialView addSubview:lockedView];
    }
    else {
        [initialView addSubview:disclaimerView];
    } 
    
	NSLog(@"Axiom - Setting up modules");
	[self performSelector:@selector(startInitalLoadingProcedure) withObject:nil afterDelay:2.0];
    
    //**********************************************
    // This is set up for a maximum 16k tracks
    // ITUNES STUFF HERE
    //*********************************************
    tracksArray = [[NSMutableArray alloc] init];
    
	//set here to remember playlist used
	playlistNumber = [defaults integerForKey:@"LastPlaylist"];
	
	if (playlistNumber < 1) {
		playlistNumber = 1;
	}
	else if (playlistNumber > [playlistArray count]){
		playlistNumber = [playlistArray count] - 1;
	}
    
    playlistNumber = 1;
	
    [self iTunesStuffWithListNumber:0];
	
    [self.iTunes stop];
    
    [volumeSlider setContinuous:YES];
	
	float vol;
	vol = [defaults floatForKey:@"Vol"];
	if (vol <100.0f) {
		vol = 100.0;
	}
    [self setVolume_Itunes_Slider:vol];
    
	
    updateCountDown = 0;
	
    iTunesShouldBePlaying = NO;//[defaults boolForKey:@"iTunesPlay"];
	
	
	//get user prefs
	
	shouldShuffle = [defaults boolForKey:@"Shuffle"];
	if (shouldShuffle) {
		//[shuffleButton setTitle:@"Shuffle On"];
		[shuffleButton setImage:[NSImage imageNamed:@"shuffleOnButton.png"]];
	}
	else {
		[shuffleButton setImage:[NSImage imageNamed:@"shuffleOffButton.png"]];
	}
	
	shouldRepeat = [defaults boolForKey:@"Repeat"];
	if (shouldRepeat) {
		[repeatButton setImage:[NSImage imageNamed:@"repeatAllButton.png"]];
	}
	else {
		[repeatButton setImage:[NSImage imageNamed:@"repeatOffButton.png"]];
	}
	
	
    // *************************************
    // THIS WILL MAKE THE APP RUN FULLSCREEN
    // *************************************
    
	//[self fullscreen];
	//NSRect theScreenFrame = [[NSScreen mainScreen] frame];
	//NSRect theScreenFrame = [[self screen] frame];
	
	[window setBackgroundColor:[NSColor blackColor]];
    [window setDelegate:self];
    [playListSelectButton setTarget:self];
    NSLog(@"Axiom - User is using Mac OSX %@",[AxiomAppDelegate getSystemVersion]);
    
#ifdef DEBUG
    if ([[AxiomAppDelegate getSystemVersion] doubleValue] >= 10.7) {
        [playListButton setHidden:YES];
        [playListSelectButton setAction:@selector(showPlaylistPopover:)];
        [self performSelector:@selector(playStartUpSound) withObject:nil afterDelay:2.0];
    }
    else{
        [window setBackingType:NSBackingStoreBuffered];
        SetSystemUIMode (kUIModeAllHidden, kUIOptionAutoShowMenuBar);
        [window setStyleMask:NSBorderlessWindowMask];
        [window canBecomeKeyWindow]; 
        [playListButton setHidden:NO];
        [playListSelectButton setAction:@selector(clickPlaylist:)];
        
    }
    
    NSLog(@"Axiom - Build: Debug, Version: %@",[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"]);
#else 
    //RELEASE
    if ([[AxiomAppDelegate getSystemVersion] doubleValue] >= 10.7) {
        [self performSelector:@selector(playStartUpSound) withObject:nil afterDelay:2.0];
        [window setBackingType:NSBackingStoreBuffered];
        [window setStyleMask:NSBorderlessWindowMask];
        [window canBecomeKeyWindow];
        [playListButton setHidden:YES];
        [playListSelectButton setAction:@selector(showPlaylistPopover:)];

    }
    else{
        [window setBackingType:NSBackingStoreBuffered];
        SetSystemUIMode (kUIModeAllHidden, kUIOptionAutoShowMenuBar);
        [window setStyleMask:NSBorderlessWindowMask];
        [window canBecomeKeyWindow];
        [playListButton setHidden:NO];
        [playListSelectButton setAction:@selector(clickPlaylist:)];
        
    }
    
    [self toggleFullscreen:self];

    NSLog(@"Axiom - Build: Release, Version: %@",[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"]);
#endif

    
    
    NSRect rectFor480 = NSRectFromCGRect(CGRectMake(0, 0, rootView.frame.size.width, [self contentHeight]));
        usingBigScreen = YES;
		[menuView setFrame:rectFor480];
		[musicView setFrame:rectFor480];
		[webView setFrame:rectFor480];
		[weatherView setFrame:rectFor480];
		[updateView setFrame:rectFor480];
		[settingsView setFrame:rectFor480];
		[volumeView setFrame:rectFor480];
		//[visualsView setFrame:rectFor480];
    
	[window setHasShadow:NO];
    [window becomeFirstResponder];
	[window makeKeyAndOrderFront:self];

}

- (IBAction)toggleFullscreen:(id)sender
{
    if ([rootView isInFullScreenMode] == NO)
    {
        [self fadeOut];
        [rootView enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];
        [self fadeIn];
    }
    else
    {
        [self fadeOut];
        [rootView exitFullScreenModeWithOptions:nil];
        [self fadeIn];
    }
}

- (void)fadeOut
{
    CGDisplayErr    err;
    
    err = CGAcquireDisplayFadeReservation(kCGMaxDisplayReservationInterval, &token);
    if (err == kCGErrorSuccess)
    {
        CGDisplayFade(token, 1.5, kCGDisplayBlendNormal, kCGDisplayBlendSolidColor, 0, 0, 0, TRUE);
    }
}

- (void)fadeIn
{
    CGDisplayErr    err;
    
    err = CGDisplayFade(token, 1.5, kCGDisplayBlendSolidColor, kCGDisplayBlendNormal, 0, 0, 0, TRUE);
    if (err == kCGErrorSuccess)
    {
        CGReleaseDisplayFadeReservation(token);
    }
}


+(NSString*)getSystemVersion{
    NSString *versionString;
    NSDictionary * sv = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
    versionString = [sv objectForKey:@"ProductVersion"];
    
    return versionString;
}

-(void)windowWillEnterFullScreen:(NSNotification *)notification{
    [window setFrame:[[self screen] frame] display: YES animate: NO];
}
- (void)windowDidEnterFullScreen:(NSNotification *)notification{
    [window makeKeyAndOrderFront:self];
}

-(void)windowDidExitFullScreen:(NSNotification *)notification{
    NSRect rectFor480 = NSRectFromCGRect(CGRectMake(0, 0, rootView.frame.size.width, 370));
    usingBigScreen = YES;
    [menuView setFrame:rectFor480];
    [musicView setFrame:rectFor480];
    [webView setFrame:rectFor480];
    [weatherView setFrame:rectFor480];
    [updateView setFrame:rectFor480];
    [settingsView setFrame:rectFor480];
    [volumeView setFrame:rectFor480];
    //[visualsView setFrame:rectFor480];
}


-(void)setupScripts{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// Setup the AppleScripts
    prevTrackScript = [[NSString alloc] initWithString:@"tell application \"iTunes\" to previous track"];
    playScript = [[NSString alloc] initWithString:@"tell application \"iTunes\" to play"];
    pauseScript = [[NSString alloc] initWithString:@"tell application \"iTunes\" to pause"];
    nextTrackScript = [[NSString alloc] initWithString:@"tell application \"iTunes\" to next track"];
    shuffleOnScript = [[NSString alloc] initWithString:@"tell application \"iTunes\" to set shuffle of current playlist to true"];
    shuffleOffScript = [[NSString alloc] initWithString:@"tell application \"iTunes\" to set shuffle of current playlist to false"];
    repeatAllScript = [[NSString alloc] initWithString:@"tell application \"iTunes\" to set song repeat of current playlist to all"];
    repeatOneScript = [[NSString alloc] initWithString:@"tell application \"iTunes\" to set song repeat of current playlist to one"];
    repeatOffScript = [[NSString alloc] initWithString:@"tell application \"iTunes\" to set song repeat of current playlist to off"];
    playerInfoScript = [[NSString alloc] initWithString:@"set info to {}\ntell application \"iTunes\"\nset info to info & {(player position)}\nset info to info & {(duration of current track as integer)}\nset info to info & {(player state as string)}\nset info to info & {(shuffle of current playlist)}\nset info to info & {(song repeat of current playlist as string)}\nset info to info & {(id of current track)}\nset val to 0\ntry\nset val to index of current track\nend try\nset info to info & val\nset info to info & {count tracks of current playlist}\nend tell\nget info"];
    trackInfoScript = [[NSString alloc] initWithString:@"set info to {}\ntell application \"iTunes\"\nset info to info & {(artist of current track)}\nset info to info & {(album of current track)}\nset info to info & {(name of current track)}\ntry\nset info to info & {(data of (get first artwork of current track))}\nend try\nend tell\nget info"];
    playlistsScript = [[NSString alloc] initWithString:@"set info to {}\ntell application \"iTunes\"\nrepeat with s in sources\nset x to {}\nset x to x & name of s\nset x to x & kind of s\nset ps to {}\nrepeat with p in playlists of s\nset ps to ps & name of p\nend repeat\nset x to x & {ps}\nset info to info & {x}\nend repeat\nend tell\nget info"];
    
    currentPlaylistNameScript = [[NSString alloc] initWithString:@"tell application \"iTunes\" to get name of container of current playlist & \": \" & name of current playlist"];
	currentPlaylistScript = [[NSString alloc] initWithString:@"tell application \"iTunes\"\n set thePlaylist to current playlist\n set theCurrentPlaylistName to thePlaylist\'s name\n copy name of current playlist to theCurrentPlaylistName\n return theCurrentPlaylistName\n end tell "];
    
    NSLog(@"Axiom - Setting up modules...DONE");
	[pool release];		
	
    
}
#pragma mark End Main App Methods



#pragma mark Start License Checks
-(void)countForLicenseTime{
	licenseCount++;
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
	[d setInteger:licenseCount forKey:@"LicenseCount"];
    
	
	if (licenseCount >= trialTime) {
		[self clickTimerLicense];
	}
}
-(void)clickTimerLicense{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	timesUp = YES;
	[defaults setBool:timesUp forKey:@"TimesUp"];
    
	[self checkForLicense];
}
-(void)checkForLicense{
	NSFileManager *file = [[NSFileManager alloc] init];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSLog(@"Axiom - Checking For Axiom License");
	
	if (timesUp && activated == NO) {
		if ([file fileExistsAtPath:LICENSE_INSTALL]) {
			NSLog(@"Axiom - User Has License");
			activated = YES;
			[initialView setHidden:NO];
			[initialView addSubview:disclaimerView];
			appLocked = NO;
			if ([checkForLicenseTimer isValid]) {
				[checkForLicenseTimer invalidate];
				NSLog(@"Axiom - License Timer Invalidated");
			}
			
		}
		else{
			NSLog(@"Axiom - User Does NOT have License!!!");
			[initialView setHidden:NO];
			if (disclaimerView) {
				[disclaimerView removeFromSuperview];
			}
			[mainContentView setHidden:YES];
			[initialView addSubview:lockedView];
			[nextButton setHidden:YES];
			[prevButton setHidden:YES];
            [quitButton setHidden:YES];
			[self performSelector:@selector(exitNoLicense) withObject:nil afterDelay:15.0];
            
			activated = NO;
			appLocked = YES;
			if ([checkForLicenseTimer isValid]) {
				[checkForLicenseTimer invalidate];
				NSLog(@"Axiom - License Timer Invalidated");
			}
		}
	}
	
	
	[defaults setBool:timesUp forKey:@"TimesUp"];
	[defaults setBool:appLocked forKey:@"AppLocked"];
    [defaults synchronize];
	[file autorelease];
	
}
#pragma mark End License Checks

#pragma mark Start Loading Procedures
-(void)incrementLoading{
	static int i;
	[initialLoading incrementBy:2];	
	i = i+2;
	if (i == 100) {
		[loadingTimer invalidate];
		loadingTimer = nil;
		NSLog(@"Axiom - Loading finished! Enjoy. For support contact support@bluehawksolutions.com");
	}
}
-(void)startInitalLoadingProcedure{
	loadingTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(incrementLoading) userInfo:nil repeats:YES];
	[initialLoading startAnimation:self];
	[initialLoadingText setStringValue:@"Looking for license..."];
	[self performSelector:@selector(startInitalLoadingProcedure1) withObject:nil afterDelay:2.0];
	
}
-(void)startInitalLoadingProcedure1{
	[initialLoadingText setStringValue:@"Loading artwork..."];
	[self performSelector:@selector(startInitalLoadingProcedure2) withObject:nil afterDelay:1.5];
	
}
-(void)startInitalLoadingProcedure2{
	[initialLoadingText setStringValue:@"Loading weather manager..."];
	[self performSelector:@selector(startInitalLoadingProcedure3) withObject:nil afterDelay:1.5];
	
}
-(void)startInitalLoadingProcedure3{
	[initialLoadingText setStringValue:@"Loading complete"];
	[self performSelector:@selector(startInitalLoadingProcedure4) withObject:nil afterDelay:1.0];
	
}
-(void)startInitalLoadingProcedure4{
	[initialLoading setHidden:YES];
	[initialLoadingText setHidden:YES];
	[agreeButton setHidden:NO];
}
#pragma mark End Loading Procedures


#pragma mark Start Music Navigation Buttons
-(IBAction)UpNavButton:(id)sender{
	//NSLog(@"Axiom - Got Current Index UP BTN = %i",currentTrackIndexField);
	//moving up minus the current index
	[self getNewTrackIndex];
    [leftNavButton setEnabled:YES];
	if (!currentScrollIndex && didPushDown == NO) {
		currentScrollIndex = currentTrackIndexField;
	}
	int moveAmount = 2;
	didPushUp = YES;
	
	if (changedSong) {
		currentScrollIndex = currentTrackIndexField;
		changedSong = NO;
	}
    
	if (didPushDown == YES) {
		currentScrollIndex = currentScrollIndex - (moveAmount*2);
		didPushDown = NO;
	}
	else {
		currentScrollIndex = currentScrollIndex - moveAmount;
	}
	
	if (currentScrollIndex < 3) {
		currentScrollIndex = 0;
		[rightNavButton setEnabled:NO];
	}
	
	[table scrollRowToVisible:currentScrollIndex];
}
-(IBAction)DownNavButton:(id)sender{
	//NSLog(@"Axiom - Got Current Index DOWN BTN = %i",currentTrackIndexField);
	//moving down adds the current index
	[self getNewTrackIndex];
	[rightNavButton setEnabled:YES];
	
	if (!currentScrollIndex && didPushUp == NO) {
		currentScrollIndex = currentTrackIndexField;
	}
	int moveAmount = 2;
	didPushDown = YES;
	if (changedSong) {
		currentScrollIndex = currentTrackIndexField;
		changedSong = NO;
	}
    
	if (didPushUp == YES) {
		currentScrollIndex = currentScrollIndex + (moveAmount*2);
		didPushUp = NO;
	}
	else {
		currentScrollIndex = currentScrollIndex + moveAmount;
	}
	
	if (currentScrollIndex >= ([tracksArray count]-5)) {
		//NSLog(@"Axiom - Track Count - %i",[tracksArray count]);
		currentScrollIndex = [tracksArray count]-1;
        [leftNavButton setEnabled:NO];
		
	}
	
	
	[table scrollRowToVisible:currentScrollIndex];
	
}
#pragma mark End Music Navigation Buttons


#pragma mark Start Music Controls 
-(IBAction)playPause:(id)sender{
    
	
    if (iTunesShouldBePlaying == NO)
    {
        //PLAY
        iTunesShouldBePlaying = YES;
		[playPauseButton setImage:[NSImage imageNamed:@"pauseButton.png"]];
		[vViewSmall startRendering];
        [self.iTunes playpause];
        
    }
    else if(self.iTunes.playerState == iTunesEPlSPlaying || iTunesShouldBePlaying == YES)
    {
        //PAUSE
        iTunesShouldBePlaying = NO;
		[playPauseButton setImage:[NSImage imageNamed:@"playButton.png"]];
		//[vViewSmall stopRendering];
        [self.iTunes playpause];
    }
    
    
    [self getNewTrackIndex];
}
-(IBAction)next:(id)sender{
    
	[self.iTunes nextTrack];
	[self getNewTrackIndex];
    
	[table scrollRowToVisible:currentTrackIndexField];
    
    
	changedSong = YES;
    
}
-(IBAction)prev:(id)sender{
	int position = self.iTunes.playerPosition;
    NSString* minuteStr = nil;
    NSString* secondStr = nil;
    
    int minutes = position / 60;
    
    int seconds = position % 60;
    
    if ( seconds < 10 )
    {
        secondStr = [NSString stringWithFormat:@"0%d",seconds];
    }
    else 
    {
        secondStr = [NSString stringWithFormat:@"%d",seconds];
    }
	
    if ( minutes < 10 )
    {
        minuteStr = [NSString stringWithFormat:@"0%d",minutes];
    }
    else 
    {
        minuteStr = [NSString stringWithFormat:@"%d",minutes];
    }
	
	
	
	if (seconds > 2) {
		self.iTunes.playerPosition = 0;
	}
	else {
		[self.iTunes previousTrack];
		[self getNewTrackIndex];
        [table scrollRowToVisible:currentTrackIndexField];
    }
	
}
-(IBAction)toggleShuffle:(id)sender{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	shouldShuffle = [defaults boolForKey:@"Shuffle"];
	NSDictionary            *error = nil;
	NSString           *script = nil;
	NSAppleEventDescriptor  *res = nil;
	
	if (shouldShuffle) {
		shouldShuffle = NO;
		script = shuffleOffScript;
		[shuffleButton setImage:[NSImage imageNamed:@"shuffleOffButton.png"]];
		//[shuffleButton setTitle:@"Shuffle Off"];
		
	}
	else {
		shouldShuffle = YES;
		//[shuffleButton setTitle:@"Shuffle On"];
		script = shuffleOnScript;
		[shuffleButton setImage:[NSImage imageNamed:@"shuffleOnButton.png"]];
	}
	
	res = [self runWithSource:script andReturnError:&error];
	if (error != nil) {
		NSLog(@"Axiom - Shuffle Mode: %@", [error objectForKey:@"NSAppleScriptErrorMessage"]);
		return;
	}
	
	[self clickPlaylist:nil];
	[defaults setBool:shouldShuffle forKey:@"Shuffle"];
	[defaults synchronize];
}
-(IBAction)toggleRepeat:(id)sender{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	shouldRepeat = [defaults boolForKey:@"Repeat"];
	NSDictionary            *error = nil;
	NSString           *script = nil;
	NSAppleEventDescriptor  *res = nil;
	
	if (shouldRepeat) {
		shouldRepeat = NO;
		script = repeatOffScript;
		//[repeatButton setTitle:@"Repeat Off"];
		[repeatButton setImage:[NSImage imageNamed:@"repeatOffButton.png"]];
	}
	else {
		shouldRepeat = YES;
		//[repeatButton setTitle:@"Repeat ALL"];
		script = repeatAllScript;
		[repeatButton setImage:[NSImage imageNamed:@"repeatAllButton.png"]];
	}
	
	
	
	res = [self runWithSource:script andReturnError:&error];
	if (error != nil) {
		NSLog(@"Axiom - Repeat Mode: %@", [error objectForKey:@"NSAppleScriptErrorMessage"]);
		return;
	}
	
	
	[defaults setBool:shouldRepeat forKey:@"Repeat"];
	[defaults synchronize];
	
	
	
}
-(IBAction)showVolume:(id)sender{
	static BOOL isShowingVol;
	if (isShowingVol == NO) {
		//[volumeSlider setHidden:NO];
		isShowingVol = YES;
		isShowingVolumeView = YES;
		[self.mainContentView addSubview:volumeView];
		[volumeButton setImage:[NSImage imageNamed:@"volumeOnButton.png"]];
		[quitButton setEnabled:NO];
		/*[volumeButton setFrame:NSRectFromCGRect(CGRectMake(11, 12, 60, 53))];
		 NSTimer *timer;
		 timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(showVolume:) userInfo:nil repeats:NO];*/
        [vViewSmall setHidden:YES];
	}
	else {
		//[volumeSlider setHidden:YES];
		isShowingVol = NO;
		isShowingVolumeView = NO;
		[volumeButton setImage:[NSImage imageNamed:@"volumeButton.png"]];
		[quitButton setEnabled:YES];
		[volumeView removeFromSuperview];
        [vViewSmall setHidden:NO];
	}
	
	
}
-(IBAction)sliderDidSomething:(id)sender{ 
    NSLog(@"Axiom - %f",[volumeSlider floatValue]);
	//   self.iTunes.soundVolume = (int) [volumeSlider floatValue];
    [self setVolume_Itunes_Slider:[volumeSlider floatValue]];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:[volumeSlider floatValue] forKey:@"Vol"];
	[defaults synchronize];
}
-(void)setVolume_Itunes_Slider:(float)volume{
    self.iTunes.soundVolume = (int)volume;
    [volumeSlider setFloatValue:volume];
}


-(void)fadeVolume:(NSString *)direction{
    if ([direction isEqualToString:@"in"]) {
        self.iTunes.soundVolume = 0.0;
        volumeTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(increaseVol) userInfo:nil repeats:YES];
        
    }
    else {
        volumeTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(decreaseVol) userInfo:nil repeats:YES]; 
    }
}

-(void)increaseVol{
    self.iTunes.soundVolume += 20;
    if (self.iTunes.soundVolume == 100) {
        [volumeTimer invalidate];
    }
}

-(void)decreaseVol{
    self.iTunes.soundVolume -= 20;
    if (self.iTunes.soundVolume == 0) {
        [volumeTimer invalidate];
    }
}


-(IBAction)showVisuals:(id)sender{
	
	if (self.iTunes.currentTrack.videoKind == iTunesEVdKNone) {
		isShowingVisuals = YES;
        //((NSView*)visualsView.animator).frame = window.frame;
        visualsView.frame = NSRectFromCGRect(CGRectMake(0, 0, [self window].frame.size.width, [self window].frame.size.height));
		[[window contentView] addSubview:visualsView];
		
	}
	else if(self.iTunes.currentTrack.videoKind == iTunesEVdKMovie || self.iTunes.currentTrack.videoKind == iTunesEVdKTVShow || self.iTunes.currentTrack.videoKind == iTunesEVdKMusicVideo){
		//NSString* src1 = [NSString stringWithFormat:@"tell application \"iTunes\" to activate\n tell application \"System Events\"\n keystroke \"f\" using command down\nend tell"];;
        NSString* src1;
        if([[AxiomAppDelegate getSystemVersion] doubleValue] >= 10.7){
            src1 = [NSString stringWithFormat:@"tell application \"iTunes\"\n activate\n end tell\n tell application \"System Events\"\n keystroke \"f\" using command down\n end tell\n end tell"];
        }
        else {
            src1 = [NSString stringWithFormat:@"tell application \"iTunes\"\n activate\n end tell\n tell application \"System Events\"\n keystroke \"f\" using command down\n end tell\n tell application \"iTunes\"\n tell browser window 1\n set collapsed to true\n end tell\n end tell"];
        }
		NSAppleScript* script1 = [[NSAppleScript alloc] initWithSource:src1];
		NSDictionary* error1;
		[script1 executeAndReturnError:&error1];
		[script1 autorelease];
        
		
		
		/*NSTimer *visualsTimerA;
         if (![visualsTimer isValid]) {
         visualsTimerA = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(fireTimerForCheck) userInfo:nil repeats:NO];
         NSLog(@"Axiom - Creating Visuals Timer");
         }
         else {
         NSLog(@"Axiom - Timer already started no need to start again!");
         }*/
		
		
	}
	
}
#pragma mark End Music Controls


#pragma mark Start Playlist Methods
-(IBAction)scrollToCurrentSong:(id)sender{
	[table scrollRowToVisible:currentTrackIndexField];	
}
-(void)getNewTrackIndex{
    NSDictionary            *error = nil;
    NSAppleEventDescriptor  *res = nil;
    
    res = [self runWithSource:playerInfoScript andReturnError:&error];	
    
	//NSLog(@"Axiom - The Player Info - %@",res);
	// Track index & count
    int trackIndex = [[res descriptorAtIndex:7] int32Value];
    //[currentTrackIndexField setIntValue:trackIndex];
	currentTrackIndexField = trackIndex;
	//NSLog(@"Axiom - Got new Index = %i",currentTrackIndexField);
    int trackCount = [[res descriptorAtIndex:8] int32Value];
	//[trackCountField setIntValue:trackCount];
	trackCountField = [NSString stringWithFormat:@"%i",trackCount];
}
-(void)resetPlaylists{
	iTunesSource *library = [[self.iTunes sources] objectAtIndex:0];
    if (playlistNumber <1) {
		playlistNumber = 0;
	}
    SBElementArray* playLists = [library userPlaylists];
	iTunesLibraryPlaylist *i = [playLists objectAtIndex:playlistNumber];
	//NSArray *a = [[NSArray alloc] initWithArray:playLists];
	NSLog(@"Axiom - %@",i.name);
	if (i.name == nil) {
		[playListSelectButton setTitle:@"No More Playlists"];
		[playListSelectButton setEnabled:NO];
	}
	else{
		[playListSelectButton setTitle:i.name];
		[playListSelectButton setEnabled:YES];
		
	}	
}
-(IBAction)iTunesStuffWithListNumber:(int)number{
    iTunesSource *library = [[self.iTunes sources] objectAtIndex: 0];
    
    SBElementArray* playLists = [library userPlaylists];
    if (!tracksArray) {
		tracksArray = [[NSMutableArray alloc] initWithCapacity:1024*36];
	}
	
	
	
    iTunesLibraryPlaylist *i = [playLists objectAtIndex:number];
    
    SBElementArray* trax = [i tracks];
	
    for ( iTunesTrack* T in trax )
    {
		
        [tracksArray addObject:T];
        
    }
	
    [table reloadData];
	
}
-(void)clearTracks{
	if ([tracksArray objectAtIndex:0] != nil) {
		[tracksArray removeAllObjects];
		NSLog(@"Axiom - Cleared the tracks array!");
	}	
}
/*-(IBAction) selectPlaylist: (id) sender {
 NSDictionary            *error = nil;
 NSString                *script = nil;
 NSAppleEventDescriptor  *res = nil;
 NSDictionary            *list = [[sourceList selectedObjects] objectAtIndex:1];
 
 if (list == nil) return;
 
 NSString    *source = [list objectForKey:@"source"];
 NSString    *playlist = [list objectForKey:@"playlist"];
 if ([[list objectForKey:@"type"] isEqualToString:@"library"]) {
 script = [NSString
 stringWithFormat:@"tell application \"iTunes\" to play playlist \"%@\"",
 playlist];
 } else {
 script = [NSString
 stringWithFormat:@"tell application \"iTunes\" to tell source \"%@\" to play playlist \"%@\"",
 source, playlist];
 }
 res = [self runWithSource:script andReturnError:&error];
 if (error != nil) {
 NSLog(@"Axiom - iTunesViewController: selectPlaylist: %@: %@",
 source, [error objectForKey:@"NSAppleScriptErrorMessage"]);
 return;
 }
 }*/


-(IBAction)showPlaylistPopover:(id)sender{
    if (self.playlistPopover == nil)
    {
        // create and setup our popover
        playlistPopover = [[NSPopover alloc] init];
        
        // the popover retains us and we retain the popover,
        pController = [[PlaylistController alloc] initWithNibName:@"PlaylistController" bundle:nil];
        pController.playlistArray = playlistArray;
        self.playlistPopover.contentViewController = pController;
        self.playlistPopover.appearance = NSPopoverAppearanceHUD;
        self.playlistPopover.animates = YES;
        
        // AppKit will close the popover when the user interacts with a user interface element outside the popover.
        // note that interacting with menus or panels that become key only when needed will not cause a transient popover to close.
        self.playlistPopover.behavior = NSPopoverBehaviorTransient;
        
        // so we can be notified when the popover appears or closes
        self.playlistPopover.delegate = self;
    }
    [popoverPosition setState:1 atRow:0 column:0];
    NSRectEdge prefEdge = 0;
    closePL = YES;
    [self.playlistPopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:prefEdge];
}


//methods used for music navigation
-(void)updateSourceList:(id)arg {
	//start dispatch
	dispatch_queue_t queueA, queueB, queueTar;
	queueA = queueB = dispatch_queue_create("com.bluehawk.axiom.sourceL", NULL);
	queueTar = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	dispatch_set_target_queue(queueTar, queueA);
	
    
    NSDictionary            *error = nil;
    NSAppleEventDescriptor  *res = nil;
	
    //FIRST MESS UP
    res = [self runWithSource:playlistsScript andReturnError:&error];
    if (error != nil) {
        NSLog(@"Axiom - updateSourceList: playlists: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        return;
    }
    
    [sourceList removeObjects:[sourceList content]];
	
	dispatch_async(queueA, ^{
        int     i = 0;
        for (i = 1 ; i <= [res numberOfItems] ; i++) {
            NSAppleEventDescriptor  *s = [res descriptorAtIndex:i];
            NSString *source = [[s descriptorAtIndex:1] stringValue];
            NSString *type = [[s descriptorAtIndex:2] stringValue];
            NSAppleEventDescriptor  *lists = [s descriptorAtIndex:3];
            
            dispatch_async(queueB, ^{
                int c = 0;
                for (c = 1 ; c <= [lists numberOfItems] ; c++) {
                    NSMutableDictionary *el = [NSMutableDictionary dictionary];
                    NSString *list = [[lists descriptorAtIndex:c] stringValue];
                    
                    
                    [el setObject:[NSString stringWithFormat:@"%@: %@", source, list] forKey:@"displayName"];
                    [el setObject:source forKey:@"source"];
                    [el setObject:type forKey:@"type"];
                    [el setObject:list forKey:@"playlist"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [sourceList addObject:el];
                        
                    });
                }
            });
        }
        
        //res = [self runWithSource:currentPlaylistScript andReturnError:&error];
        if (error != nil) {
            NSLog(@"Axiom - iTunesViewController: fastTimer: playlist: %@",
                  [error objectForKey:@"NSAppleScriptErrorMessage"]);
        } else {
            NSArray     *playlists = [sourceList content];
            NSString    *name = [res stringValue];
            int         i = 0;
            
            for (i = 0 ; i < [playlists count] ; i++) {
                if ([name isEqualToString:[[playlists objectAtIndex:i]
                                           objectForKey:@"displayName"]]) {
                    [sourceList setSelectionIndex:i];
                    break;
                }
            }
            //if (i == [playlists count]) [sourceList setSelectionIndex:0];
        }
	});
	
	dispatch_release(queueA);
    dispatch_release(queueTar);
}
-(IBAction)cyclePlaylists:(id)sender andPlaylistNumber:(NSInteger)playlistNum{
	iTunesSource *library = [[self.iTunes sources] objectAtIndex:0];
    if (playlistNumber <1) {
		playlistNumber = 0;
	}
    SBElementArray* playLists = [library userPlaylists];
	iTunesLibraryPlaylist *i = [playLists objectAtIndex:playlistNumber];
	NSArray *a = [[NSArray alloc] initWithArray:playLists];
	//NSLog(@"Axiom - %@ - %i",i.name, playlistNumber);
	if (i.name == nil) {
		[playListSelectButton setTitle:@"No More Playlists"];
		[playListSelectButton setEnabled:NO];
	}
	else{
		[playListSelectButton setTitle:i.name];
		[playListSelectButton setEnabled:YES];
		
	}
    
    if(self.menuShowing == NO){
        playlistNumber++;
    }
	if (playlistNumber >= [a count]) {
		playlistNumber = 0;
		//NSLog(@"Axiom - ------======== Playlist Reset ==========------");
	}
	[a autorelease];//check here
	
	NSColor *color = [NSColor whiteColor];
	
	NSMutableAttributedString *colorTitle =
	[[NSMutableAttributedString alloc] initWithAttributedString:[playListSelectButton attributedTitle]];
	
	NSRange titleRange = NSMakeRange(0, [colorTitle length]);
	
	[colorTitle addAttribute:NSForegroundColorAttributeName
					   value:color
					   range:titleRange];
	
	[playListSelectButton setAttributedTitle:colorTitle];
	[colorTitle autorelease];
	
}
-(IBAction)cyclePlaylistsBack:(id)sender andPlaylistNumber:(NSInteger)playlistNum{//needs work GLITCHY
	iTunesSource *library = [[self.iTunes sources] objectAtIndex:0];
    
    SBElementArray* playLists = [library userPlaylists];
	iTunesLibraryPlaylist *i = [playLists objectAtIndex:playlistNumber];
	NSArray *a = [[NSArray alloc] initWithArray:playLists];
    if(playlistNumber > [a count]){
        playlistNumber = 0;
    }
	NSLog(@"Axiom - %@ - %i",i.name, playlistNumber);
	if (i.name == nil) {
		[playListSelectButton setTitle:@"No More Playlists"];
		[playListSelectButton setEnabled:NO];
	}
	else{
		[playListSelectButton setTitle:i.name];
		[playListSelectButton setEnabled:YES];
		
	}
    
    if(self.menuShowing == NO){
        playlistNumber--;
    }
	if (playlistNumber < 0) {
		playlistNumber = [a count]-1;
		//NSLog(@"Axiom - ------======== Playlist Reset ==========------");
	}
	[a autorelease];//check here
	
	NSColor *color = [NSColor whiteColor];
	
	NSMutableAttributedString *colorTitle =
	[[NSMutableAttributedString alloc] initWithAttributedString:[playListSelectButton attributedTitle]];
	
	NSRange titleRange = NSMakeRange(0, [colorTitle length]);
	
	[colorTitle addAttribute:NSForegroundColorAttributeName
					   value:color
					   range:titleRange];
	
	[playListSelectButton setAttributedTitle:colorTitle];
	[colorTitle autorelease];
	
}
-(IBAction)clickPlaylist:(id)sender{
	//start dispatch
	dispatch_queue_t queueA, queueTar;
	queueA = dispatch_queue_create("com.bluehawk.axiom.clickP", NULL);
	queueTar = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	dispatch_set_target_queue(queueTar, queueA);
	
    
	if ((self.menuShowing == YES && self.iTunes.playerState == iTunesEPlSPlaying) || self.iTunes.playerState == iTunesEPlSPaused) {
		NSLog(@"Axiom - We dont need to reload the songs!");
        [self refreshPlayList:nil];
	}
	else {
        
		NSLog(@"Axiom - Loading Music...");
		[songTitle setStringValue:@"Loading..."];
        
		//[self clearTracks];
		if (tracksArray == nil) {
			tracksArray = [[NSMutableArray alloc] initWithCapacity:1024*32];
		}
		else {
			[tracksArray removeAllObjects];
			tracksArray = nil;
			tracksArray = [[NSMutableArray alloc] initWithCapacity:1024*32];
		}
		
        dispatch_async(queueA, ^{
            if(playlistNumber < 1){
                playlistNumber = 1;
            }
            iTunesSource *library = [[self.iTunes sources] objectAtIndex: 0];
            SBElementArray* playLists = [library userPlaylists];
            iTunesLibraryPlaylist *i = [playLists objectAtIndex:playlistNumber-1];
            SBElementArray* trax = [i tracks];
            
            for (iTunesTrack* T in trax){
                [tracksArray addObject:T];
            }

                if([tracksArray count] == 0){
                    NSLog(@"Axiom - Error reading songs... trying again...");
                    [songTitle setStringValue:@"Select a playlist to play..."];
                    for (iTunesTrack* T in trax){
                        [tracksArray addObject:T];
                    }
                    return;
                }
                else {
                    NSLog(@"Axiom - Media check passed");
                }
            
            NSLog(@"Axiom - Loading Music....DONE");
            dispatch_async(dispatch_get_main_queue(), ^{
                if([tracksArray count] != 0){
                    [table reloadData];
                    //NSLog(@"Axiom - Tracks - %@", tracksArray);
                } else {
                    [self setMainTitle:@"Searching for media..."];
                    playlistNumber++;
                    [self clickPlaylist:nil];
                }
            });
            
            
            NSAppleEventDescriptor  *res = nil;
            NSDictionary            *error = nil;
            if (i.name != nil) {
                NSString *script = [NSString stringWithFormat:@"tell application \"iTunes\" to play playlist \"%@\"",i.name];
                //NSString* src = [NSString stringWithFormat:@"tell application \"iTunes\"\nplay track \"%i\" of playlist \"%@\"\nend tell",0,i.name];
                res = [self runWithSource:script andReturnError:&error];
                if (error != nil) {
                    NSLog(@"Axiom - iTunesViewController: selectPlaylist:%@",
                          [error objectForKey:@"NSAppleScriptErrorMessage"]);
                    return;
                }
            }
            
            
            //set a bool to only hit this method once
            static BOOL togglePBtn = YES;
            if (togglePBtn) {
                togglePBtn = NO;
                //[self playPause:nil];
                
            }
            
            if (self.iTunes.playerState != iTunesEPlSPlaying) {
                [self playPause:nil];
            }
            
            [playListSelectButton setTitle:[NSString stringWithFormat:@"%@",i.name]];
            selectedPlaylistName = i.name;
            [selectedPlaylistName retain];
            currentTrackIndexField = 0;
            [self getNewTrackIndex];
            changedSong = YES;
        });
	}
	
	dispatch_async(queueA, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:playlistNumber forKey:@"LastPlaylist"];
        //NSLog(@"Axiom - Saved Playlist number %i",playlistNumber);
        
        NSColor *color = [NSColor whiteColor];
        
        NSMutableAttributedString *colorTitle =
        [[NSMutableAttributedString alloc] initWithAttributedString:[playListSelectButton attributedTitle]];
        
        NSRange titleRange = NSMakeRange(0, [colorTitle length]);
        
        [colorTitle addAttribute:NSForegroundColorAttributeName
                           value:color
                           range:titleRange];
        dispatch_async(dispatch_get_main_queue(), ^{
            [playListSelectButton setAttributedTitle:colorTitle];
        });
        [colorTitle autorelease];
	});
	
	dispatch_release(queueA);
}
-(IBAction)refreshPlayList:(id)sender{
	//start dispatch
	dispatch_queue_t queueA, queueTar;
	queueA = dispatch_queue_create("com.bluehawk.axiom.clickP", NULL);
	queueTar = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	dispatch_set_target_queue(queueTar, queueA);
	
    
    NSLog(@"Axiom - Refreshing Music...");
    [songTitle setStringValue:@"Loading..."];
    
    //[self clearTracks];
    if (tracksArray == nil) {
        tracksArray = [[NSMutableArray alloc] initWithCapacity:1024*32];
    }
    else {
        [tracksArray removeAllObjects];
        tracksArray = nil;
        tracksArray = [[NSMutableArray alloc] initWithCapacity:1024*32];
    }
    
    dispatch_async(queueA, ^{
        iTunesSource *library = [[self.iTunes sources] objectAtIndex: 0];
        SBElementArray* playLists = [library userPlaylists];
        iTunesLibraryPlaylist *i = [playLists objectAtIndex:playlistNumber-1];
        if(playlistNumber < 1){
            playlistNumber = 1;
        }
        SBElementArray* trax = [i tracks];
        
        for (iTunesTrack* T in trax){
            [tracksArray addObject:T];
        }
        
        int s;
        for (s = 0; s<3; s++) {
            if([tracksArray count] == 0){
                NSLog(@"Axiom - Error reading songs... trying again... %i", s);
                for (iTunesTrack* T in trax){
                    [tracksArray addObject:T];
                }
            }
            else {
                NSLog(@"Axiom - Media check passed");
                s = 4;
            }
        }
        
        if(s == 2){
            dispatch_sync(dispatch_get_main_queue(), ^{
                [songTitle setStringValue:@"Error - Media invalid 4433"];
            });
        }
        
        NSLog(@"Axiom - Refreshing Music....DONE");
        dispatch_async(dispatch_get_main_queue(), ^{
            if([tracksArray count] != 0){
                [table reloadData];
                //NSLog(@"Axiom - Tracks - %@", tracksArray);
            } else {
                [self setMainTitle:@"Error - Media not found."];
                [self quit:nil];
            }
        });
        
        if (self.iTunes.playerState != iTunesEPlSPlaying) {
            [self.iTunes playpause];
        }
        
        
        [playListSelectButton setTitle:[NSString stringWithFormat:@"%@",i.name]];
        selectedPlaylistName = i.name;
        [selectedPlaylistName retain];
        currentTrackIndexField = 0;
        [self getNewTrackIndex];
        [self scrollToCurrentSong:nil];
        changedSong = YES;
    });
	
	dispatch_async(queueA, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:playlistNumber forKey:@"LastPlaylist"];
        //NSLog(@"Axiom - Saved Playlist number %i",playlistNumber);
        
        NSColor *color = [NSColor whiteColor];
        
        NSMutableAttributedString *colorTitle =
        [[NSMutableAttributedString alloc] initWithAttributedString:[playListSelectButton attributedTitle]];
        
        NSRange titleRange = NSMakeRange(0, [colorTitle length]);
        
        [colorTitle addAttribute:NSForegroundColorAttributeName
                           value:color
                           range:titleRange];
        dispatch_async(dispatch_get_main_queue(), ^{
            [playListSelectButton setAttributedTitle:colorTitle];
        });
        [colorTitle autorelease];
	});
	
	dispatch_release(queueA);
    dispatch_release(queueTar);
}
//end methods used for music navigation

#pragma mark End Playlist Methods

-(void)setMainTitle:(NSString *)s{
    [songTitle setStringValue:s];
}

#pragma mark Start Admin Methods
-(void)showMenu:(BOOL)yesMeansShow{
    
    self.menuShowing = yesMeansShow;  
}
-(IBAction)quit:(id)sender{
    
	
	
    if ( self.menuShowing == NO  && self.userAgreed == YES){
		
		//define menu options here
		
		if (isShowingWebView == YES) {
			isShowingWebView = NO;
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:.2f]; // However long you want the slide to take
            //add the frame changes here to animate 
            ((NSView*)webView.animator).frame = NSMakeRect(rootView.frame.size.width, 0, rootView.frame.size.width, [self contentHeight]);
            [NSAnimationContext endGrouping];
            
		}
		if (isShowingWeatherView == YES) {
			isShowingWeatherView = NO;
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:.2f]; // However long you want the slide to take
            //add the frame changes here to animate 
            ((NSView*)weatherView.animator).frame = NSMakeRect(rootView.frame.size.width, 0, rootView.frame.size.width, [self contentHeight]);
            [NSAnimationContext endGrouping];
            
			[weatherView setHidden:YES];
			[weatherView setHidden:NO];
		}
		if (isShowingUpdateView == YES) {
			isShowingUpdateView = NO;
			[updateView setHidden:YES];
			[updateView removeFromSuperview];
			[updateView setHidden:NO];
		}
		if (isShowingSettingsView == YES) {
			isShowingSettingsView = NO;
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:.2f]; // However long you want the slide to take
            //add the frame changes here to animate 
            ((NSView*)settingsView.animator).frame = NSMakeRect(rootView.frame.size.width, 0, rootView.frame.size.width, [self contentHeight]);
            [NSAnimationContext endGrouping];
			
            [settingsView setHidden:YES];
			[settingsView setHidden:NO];
		}
		if (isShowingVolumeView == YES) {
			isShowingVolumeView = NO;
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:.2f]; // However long you want the slide to take
            //add the frame changes here to animate 
            ((NSView*)volumeView.animator).frame = NSMakeRect(rootView.frame.size.width, 0, rootView.frame.size.width, [self contentHeight]);
            [NSAnimationContext endGrouping];
		}
        
		if (isShowingMusicView == YES && isShowingVisuals == NO) {
            isShowingMusicView = NO;
			//[vViewSmall stopRendering];
            
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:.2f]; // However long you want the slide to take
            //add the frame changes here to animate 
            ((NSView*)musicView.animator).frame = NSMakeRect(rootView.frame.size.width, 0, rootView.frame.size.width, [self contentHeight]);
            [NSAnimationContext endGrouping];
            
		}
		if (isShowingVisuals == YES) {
            isShowingVisuals = NO;
            [visualsView setHidden:YES];
            [visualsView removeFromSuperview];
            [visualsView setHidden:NO];
			
		}
        else {
            [menuView setFrame:NSMakeRect(-rootView.frame.size.width, 0, rootView.frame.size.width, [self contentHeight])];
            [mainContentView addSubview:menuView];
            [self showMenu:YES];
            
            [NSAnimationContext beginGrouping];
            [[NSAnimationContext currentContext] setDuration:.2f]; // However long you want the slide to take
            //add the frame changes here to animate 
            ((NSView*)menuView.animator).frame = NSMakeRect(0, 0, rootView.frame.size.width, [self contentHeight]);
            [NSAnimationContext endGrouping];
            NSLog(@"Axiom - Back to the menu.");
            isShowingVisuals = NO;
            isShowingMusicView = NO;
            isShowingSettingsView = NO;
            isShowingWeatherView = NO;
            isShowingWebView = NO;
        }
        
        [quitButton setTitle:@""];//QUIT
		
    }
    
    else{
        //[iTunes setSoundVolume:1];
		//[iTunes stop];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		//[defaults setBool:_menuShowing forKey:@"MenuShow"];
		//[defaults setBool:iTunesShouldBePlaying forKey:@"iTunesPlay"];
        [defaults setObject:isCelcius forKey:@"IsCelcius"];
		[defaults setInteger:playlistNumber forKey:@"LastPlaylist"];
		[defaults setObject:postalCode forKey:@"LocationNameSettings"];
		[defaults setObject:weatherCity forKey:@"WeatherSetCity"];
		[defaults synchronize];
        if ([[AxiomAppDelegate getSystemVersion] doubleValue] >= 10.7) {
#ifdef DEBUG
            NSLog(@"Axiom - Will not alter Screen");
#endif
        }
        
		if ([checkforInternet isValid]) {
			[checkforInternet invalidate];
			checkforInternet = nil;
		}
        
		if (appLocked == YES) {
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://bit.ly/a7oybN"]];
		}
        [quitButton setHidden:YES];
        [self performSelector:@selector(terminateApp) withObject:nil afterDelay:1.0];
        [self HideEverything:YES];
		NSLog(@"Axiom - GoodBye!");
        
    }
    
}
-(void)terminateApp{
    [iTunes quit];
    [self toggleFullscreen:self];
	[theApp terminate:self];
	
}
-(IBAction)hideApp:(id)sender{
    NSString * source = @"tell application \"System Events\" to set visible of process \"Axiom\" to false";
    NSAppleScript * script = [[NSAppleScript alloc] initWithSource:source];
    [script executeAndReturnError:nil];
    [script release];
}
-(void)HideEverything:(BOOL) hide{
    
    [volumeSlider setHidden:hide];
    [prevButton setHidden:hide];
    [nextButton setHidden:hide];
    [internetPic setHidden:hide];
    [playPauseButton setHidden:hide];
    [tableScroll setHidden:hide];
    [songTitle setHidden:hide];
    [songTime setHidden:hide];
	[shuffleButton setHidden:hide];
	[repeatButton setHidden:hide];
	[volumeButton setHidden:hide];
    [progressBack setHidden:hide];
    [progressFore setHidden:hide];
    [dateTextField setHidden:hide];
    [settingsLabel setHidden:!hide];
    [currentTrackLabel setHidden:hide];
	//[playListButton setHidden:hide];
	[leftNavButton setHidden:hide];
	[rightNavButton setHidden:hide];
    [disclaimerTF setHidden:!(hide)];
    [agreeButton setHidden:!(hide)];
    [hawk setHidden:!(hide)];
    
    
    [volumeSlider setAlphaValue:hide];
    [prevButton setAlphaValue:hide];
    [nextButton setAlphaValue:hide];
    [internetPic setAlphaValue:hide];
    [playPauseButton setAlphaValue:hide];
    [tableScroll setAlphaValue:hide];
    [songTitle setAlphaValue:hide];
    [songTime setAlphaValue:hide];
	[shuffleButton setAlphaValue:hide];
	[repeatButton setAlphaValue:hide];
	[volumeButton setAlphaValue:hide];
    [progressBack setAlphaValue:hide];
    [progressFore setAlphaValue:hide];
    [dateTextField setAlphaValue:hide];
    [settingsLabel setAlphaValue:!hide];
    [currentTrackLabel setAlphaValue:hide];
	//[playListButton setAlphaValue:hide];
	[leftNavButton setAlphaValue:hide];
	[rightNavButton setAlphaValue:hide];
    [disclaimerTF setAlphaValue:!(hide)];
    [agreeButton setAlphaValue:!(hide)];
    [hawk setAlphaValue:!(hide)];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:1.0];
    [[volumeSlider animator] setAlphaValue:!hide];
    [[prevButton animator] setAlphaValue:!hide];
    [[nextButton animator] setAlphaValue:!hide];
    [[internetPic animator] setAlphaValue:!hide];
    [[playPauseButton animator] setAlphaValue:!hide];
    [[tableScroll animator] setAlphaValue:!hide];
    [[songTitle animator] setAlphaValue:!hide];
    [[songTime animator] setAlphaValue:!hide];
    [[shuffleButton animator] setAlphaValue:!hide];
    [[repeatButton animator] setAlphaValue:!hide];
    [[volumeButton animator] setAlphaValue:!hide];
    [[progressBack animator] setAlphaValue:!hide];
    [[progressFore animator] setAlphaValue:!hide];
    [[dateTextField animator] setAlphaValue:!hide];
    [[settingsLabel animator] setAlphaValue:hide];
    [[currentTrackLabel animator] setAlphaValue:!hide];
    //[[playListButton animator] setAlphaValue:!hide];
    [[leftNavButton animator] setAlphaValue:!hide];
    [[rightNavButton animator] setAlphaValue:!hide];
    [[disclaimerTF animator] setAlphaValue:hide];
    [[agreeButton animator] setAlphaValue:hide];
    [[hawk animator] setAlphaValue:hide];
    [[menuView animator] setAlphaValue:!hide];
    [NSAnimationContext endGrouping];
    
}
-(IBAction)changeVis:(id)sender{
    visNumber ++;
    [self setSmallVisWithNumber:visNumber];
}
-(void)setSmallVisWithNumber:(int)index{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // Our list of all of the Quartz composer files I'm including
    NSMutableArray *visualsArray = [NSMutableArray array];
    [visualsArray addObject:@"BinaryEarth"];
    [visualsArray addObject:@"SoundstreamiTunes"];
    
    if (index >= [visualsArray count]) {
        index=0;
    }
    if (index <0) {
        index = 0;
    }
    visNumber = index;
    // Display the screen, load the file, and play it
    [vViewSmall loadCompositionFromFile: [[NSBundle mainBundle] pathForResource:[visualsArray objectAtIndex:index] ofType:@"qtz"]];
    [pool release];
}
-(IBAction) agree:(id)sender{
	//start dispatch
	dispatch_queue_t queueA, queueTar;
	queueA = dispatch_queue_create("com.bluehawk.axiom.vis1", NULL);
	queueTar = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	dispatch_set_target_queue(queueTar, queueA);
	
	dispatch_async(queueA, ^{
        self.userAgreed = YES;
        visNumber = 0;
        [self setSmallVisWithNumber:arc4random()%2];
	});
	
	updateDisplayTimer = [[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateDisplay) userInfo:nil repeats:YES] retain];
    
    [quitButton setTitle:@""];//QUIT
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [menuView setAlphaValue:0.0];
        [self.mainContentView addSubview:menuView];
        [initialView setHidden:YES];
        [self HideEverything:NO];
        
        
    });
    
	if (_menuShowing == NO) {
		[self showMenu:YES];
	}
	
	dispatch_release(queueA);
    dispatch_release(queueTar);
	
}
#pragma mark End Admin Methods
- (void)mouseDown:(NSEvent *)event
{
    NSLog(@"test");
}
#pragma mark START UPDATE DISPLAY
-(void)updateDisplay{
	//start dispatch
	dispatch_queue_t queueA, queueTar;
	queueA = dispatch_queue_create("com.bluehawk.axiom.updateDisplay", NULL);
	queueTar = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	dispatch_set_target_queue(queueTar, queueA);
	
	dispatch_async(queueA, ^{
        NSDictionary            *error = nil;
        NSAppleEventDescriptor  *res = nil;
        
        NSString* trackName  = self.iTunes.currentTrack.name; 
        NSString* artistName = self.iTunes.currentTrack.artist;
        
		dispatch_async(dispatch_get_main_queue(), ^{
            [self updateDateTime:nil];
		});
        
        if (trackName == nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //[songTitle setStringValue:@"Axiom Media"];
            });
            
            savedItunesVolume = self.iTunes.soundVolume;
            //[self playPause:nil];
            [iTunes setSoundVolume:0];
            //[self playPause:nil];
            [iTunes setSoundVolume:savedItunesVolume];
        }
        
        else 
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //[songTitle setStringValue:[NSString stringWithFormat:@"%@ by %@",trackName,artistName]];
                [songTitle setStringValue:[NSString stringWithFormat:@"%@",trackName]];
                [visTitle setStringValue:[NSString stringWithFormat:@"%@",trackName]];
                [visArtist setStringValue:[NSString stringWithFormat:@"%@",artistName]];
            });
            
        }
        
        if (self.iTunes.playerState == iTunesEPlSPlaying) {
            if (![[songTitle stringValue] isEqualTo:tempCompareTitle]) {
                tempCompareTitle = [NSString stringWithFormat:@"%@",[songTitle stringValue]];
                [self getNewTrackIndex];
                changedSong = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [table scrollRowToVisible:currentTrackIndexField-1];
                });
                [tempCompareTitle retain];
                //NSLog(@"Axiom - Auto Scroll");
                
                iTunesTrack *current = [iTunes currentTrack];
                iTunesArtwork *artwork = [[current artworks] objectAtIndex:0];
                NSImage *art = (NSImage *)[artwork data];
                
                if (art == nil || [art isKindOfClass:[NSAppleEventDescriptor class]]) {
                    [albumArtImage setImage:[NSImage imageNamed:@"emptyArt"]];
                    [visImage setImage:[NSImage imageNamed:@"emptyArt"]];
                }
                else {
                    [albumArtImage setImage:art];
                    [visImage setImage:art];
                }
                
                
                //res = [self runWithSource:trackInfoScript andReturnError:&error];
                /*// Album Art
                 if ([res numberOfItems] < 4) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                 [albumArtImage setImage:[NSImage imageNamed:@"emptyArt"]];
                 [visImage setImage:[NSImage imageNamed:@"emptyArt"]];
                 });
                 } else {
                 NSImage *art = [[[NSImage alloc] initWithData:[[res descriptorAtIndex:4] data]]
                 autorelease];
                 if ([art size].width > [albumArtImage frame].size.width ||
                 [art size].height > [albumArtImage frame].size.height) {
                 [art setScalesWhenResized:YES];
                 //[art scaleToFitSize:[albumArtImage frame].size];
                 }
                 dispatch_async(dispatch_get_main_queue(), ^{
                 [albumArtImage setImage:art];
                 [visImage setImage:art];
                 });
                 }*/
                
                
                
                if (self.iTunes.playerState == iTunesEPlSPlaying) {
                    res = [self runWithSource:playerInfoScript andReturnError:&error];	
                    // Track index & count
                    int trackIndex = [[res descriptorAtIndex:7] int32Value];
                    
                    int trackCount = [[res descriptorAtIndex:8] int32Value];
                    
                    if (trackIndex != 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [currentTrackLabel setStringValue:[NSString stringWithFormat:@"%i of %i",trackIndex,trackCount]];
                        });
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [currentTrackLabel setStringValue:@""];
                        });
                    }
                }
                
                res = [self runWithSource:playerInfoScript andReturnError:&error];
                
                // Mix Mode
                if ([[[res descriptorAtIndex:4] stringValue] isEqualToString:@"true"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [shuffleButton setImage:[NSImage imageNamed:@"shuffleOnButton.png"]];
                    });
                    shouldShuffle = YES;
                } else {
                    shouldShuffle = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [shuffleButton setImage:[NSImage imageNamed:@"shuffleOffButton.png"]];
                    });
                }
                
                if ([[[res descriptorAtIndex:5] stringValue] isEqualToString:@"off"]) {
                    shouldRepeat = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [repeatButton setImage:[NSImage imageNamed:@"repeatOffButton.png"]];
                    });
                } /*else if ([[[res descriptorAtIndex:5] stringValue] isEqualToString:@"one"]) {
                   [repeatButton setImage:repeatOneImage];
                   }*/ else {
                       shouldRepeat = YES;
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [repeatButton setImage:[NSImage imageNamed:@"repeatAllButton.png"]];
                       });
                   }
                
                /* NSDictionary            *error = nil;
                 NSAppleScript           *script = nil;
                 script = currentPlaylistNameScript;
                 res = [self runWithSource:script andReturnError:&error];
                 NSLog(@"%@",res);
                 if (error != nil) {
                 NSLog(@"Axiom - Current Playlist Name Error: %@", [error objectForKey:@"NSAppleScriptErrorMessage"]);
                 return;
                 }
                 
                 NSString *oB = [NSString stringWithFormat:@"Library: %@",[playListSelectButton stringValue]];
                 NSLog(@"a - %@  b - %@",oB, [res stringValue]);
                 //get current playlist and then compre with button
                 if(![oB isEqualToString:[res stringValue]]){
                 dispatch_async(dispatch_get_main_queue(), ^{
                 [self performSelector:@selector(refreshPlayList:) withObject:nil afterDelay:1];
                 });
                 
                 }*/
            }
            
            
            
        }
        
        
        
        int position = (int)self.iTunes.playerPosition;
        
        static int c = 0;
        if (c >= 3000) {
            c = 0;
            [self performSelector:@selector(checkNewMedia)];
        }
        else {
            c++;
        }
        
        NSString* minuteStr = nil;
        NSString* secondStr = nil;
        
        int minutes = position / 60;
        
        int seconds = position % 60;
        
        if ( seconds < 10 )
        {
            secondStr = [NSString stringWithFormat:@"0%d",seconds];
        }
        else 
        {
            secondStr = [NSString stringWithFormat:@"%d",seconds];
        }
        
        if ( minutes < 10 )
        {
            minuteStr = [NSString stringWithFormat:@"0%d",minutes];
        }
        else 
        {
            minuteStr = [NSString stringWithFormat:@"%d",minutes];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [songTime setStringValue:[NSString stringWithFormat:@"%@:%@",minuteStr,secondStr]];
		});
        
        
        int totalLength = self.iTunes.currentTrack.duration;
        
        float fRatio = (float)position / (float)totalLength;
        
        NSSize X;
        X.width = progressBack.frame.size.width * fRatio;
        X.height = progressBack.bounds.size.height;//make the back image scale with the front.
        
        [progressFore setFrameSize:X];
        
        
        /*if (iTunesShouldBePlaying == YES)
         {
         if (self.iTunes.playerState != iTunesEPlSPlaying)
         {
         if(self.iTunes.currentTrack.videoKind != iTunesEVdKMusicVideo){
         if(self.iTunes.currentTrack.videoKind != iTunesEVdKMovie){
         if(self.iTunes.currentTrack.videoKind != iTunesEVdKTVShow){
         if (updateCountDown == 0 ) {
         dispatch_async(dispatch_get_main_queue(), ^{
         [self playPause:nil];
         });
         updateCountDown = 10;
         }
         }
         }
         else 
         {
         updateCountDown--;
         }
         }
         
         }
         else 
         {
         updateCountDown = 0;
         }
         
         }*/
        
        if (self.iTunes.playerState == iTunesEPlSPlaying) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [playPauseButton setImage:[NSImage imageNamed:@"pauseButton"]];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [playPauseButton setImage:[NSImage imageNamed:@"playButton"]];
            });
        }
        
        
        if (table == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self clickPlaylist:nil];
                [table reloadData];
            });
            
            NSLog(@"Axiom - Reloading...table data");
        }
    });
    
    dispatch_release(queueA);
    dispatch_release(queueTar);
    
}
#pragma mark END UPDATE DISPLAY

#pragma mark Start Music Table Delegate/Methods
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [tracksArray count];
}
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString* objVal = nil;
    
    iTunesTrack* T = [tracksArray objectAtIndex:row];
	
    
    NSString* identifier = [tableColumn identifier];
    
    if ( [identifier isEqualToString:@"songTitle"] == YES)
    {
        objVal = [T name];
    }
    else if ( [identifier isEqualToString:@"songArtist"] == YES)
    {
        objVal = [T artist];
    }
    /*else if ( [identifier isEqualToString:@"songTime"] == YES)
     {
     int iDuration = (int)[T duration];
     int minutes = iDuration / 60;
     int seconds = iDuration % 60;
     
     
     if ( seconds < 10 )
     {
     objVal = [NSString stringWithFormat:@"%d:0%d", minutes,seconds];
     }
     else 
     {
     objVal = [NSString stringWithFormat:@"%d:%d", minutes,seconds];
     
     }*
     
     
     }*/
    else 
    {
        objVal = @"unknown column";
    }
    
    return objVal;
    
}
-(void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    [cell setTextColor:[NSColor whiteColor]];
}
-(IBAction) tableRowClicked:(id)sender{
    
    iTunesTrack* T = [tracksArray objectAtIndex:[table selectedRow]];
    
    //NSString* src = [NSString stringWithFormat:@"tell application \"iTunes\"\nplay track \"%@\" of playlist \"%@\"\nend tell\n",[T name],selectedPlaylistName];
	NSString* src = [NSString stringWithFormat:@"tell application \"iTunes\"\nplay track \"%@\" of playlist \"%@\"\nend tell",[T name],selectedPlaylistName];
	
    NSAppleScript* script = [[NSAppleScript alloc] initWithSource:src];
    
    NSDictionary* error;
    [script executeAndReturnError:&error];
	[script release];
	
	[self getNewTrackIndex];
	changedSong = YES;
	//[table scrollRowToVisible:currentTrackIndexField];
    
    
}
#pragma mark End Music Table Delegate/Methods

-(CGFloat)contentHeight{
    CGFloat y;
    y = rootView.frame.size.height-((nextButton.frame.size.height) + (songTime.frame.size.height) + (songTitle.frame.size.height) + (progressBack.frame.size.height) + (progressBack.frame.size.height)+20);
    return y;
}


#pragma mark Start Main Menu Button Actions
-(void)gotoMenu:(NSString*)menuName{
    NSView *v = nil;
    if([menuName isEqualToString:@"Media"]){
        v = musicView;
    }
    else if([menuName isEqualToString:@"Web"]){
        v = webView;
    }
    else if([menuName isEqualToString:@"Weather"]){
        v = weatherView;
    }
    else if([menuName isEqualToString:@"Settings"]){
        v = settingsView;
    }
    
    
    [v setFrame:NSMakeRect(rootView.frame.size.width, 0, rootView.frame.size.width, [self contentHeight])];
    [mainContentView addSubview:v];
	
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:.2f]; // However long you want the slide to take
	//add the frame changes here to animate 
    ((NSView*)v.animator).frame = NSMakeRect(0, 0, rootView.frame.size.width, [self contentHeight]);
    ((NSView*)menuView.animator).frame = NSMakeRect(-rootView.frame.size.width, 0, rootView.frame.size.width, [self contentHeight]);
	[NSAnimationContext endGrouping];
}


-(IBAction)menuButton23:(id)sender{
	//MUSIC
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	playlistNumber = [defaults integerForKey:@"LastPlaylist"];
    //NSLog(@"Axiom - Playlist Number - %i", playlistNumber);
	[self updateSourceList:nil];
	[self clickPlaylist:nil];
    [self scrollToCurrentSong:nil];
    [self showMenu:NO]; 
    isShowingMusicView = YES;
    [self gotoMenu:@"Media"];
    
	NSColor *color = [NSColor whiteColor];
	NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithAttributedString:[playListSelectButton attributedTitle]];
	NSRange titleRange = NSMakeRange(0, [colorTitle length]);
	[colorTitle addAttribute:NSForegroundColorAttributeName value:color range:titleRange];
	[playListSelectButton setAttributedTitle:colorTitle];
	[colorTitle autorelease];
	[vViewSmall startRendering];
}

-(IBAction)menuButton12:(id)sender{
	//web button
	[self showMenu:NO]; 
	isShowingWebView = YES;
    [self gotoMenu:@"Web"];
}

-(IBAction)menuButton13:(id)sender{
    //weather button
	[self showMenu:NO]; 
	isShowingWeatherView = YES;
    [self gotoMenu:@"Weather"];
}
-(IBAction)menuButton21:(id)sender{
    //show dashboard
	NSString* src = [NSString stringWithFormat:@"tell application \"Dashboard\"\n launch\nend tell"];
    NSAppleScript* script = [[NSAppleScript alloc] initWithSource:src];
    NSDictionary* error;
    [script executeAndReturnError:&error];
    
	[script release];
}
-(IBAction)menuButton22:(id)sender{
	//UPDATE
	[self showMenu:NO]; 
	isShowingUpdateView = YES;	
	[menuView removeFromSuperview];
	//[quitButton setTitle:@"Menu"];
	[mainContentView addSubview:updateView];
}
-(IBAction)menuButton11:(id)sender{
	//settings button
	[self showMenu:NO]; 
	isShowingSettingsView = YES;
    [self gotoMenu:@"Settings"];
	
}
#pragma mark End Main Menu Button Actions

#pragma mark Check Internet Access 
static BOOL _isDataSourceAvailable;
+ (BOOL)isDataSourceAvailable{
    
    BOOL success;
    const char *host_name = "bluehawksolutions.com";
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
    SCNetworkReachabilityFlags flags;
    success = SCNetworkReachabilityGetFlags(reachability, &flags);
    _isDataSourceAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
    CFRelease(reachability);
	
    return _isDataSourceAvailable;
}

-(BOOL)hasInternet {
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.google.com"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0];
    BOOL connectedToInternet = NO;
    if ([NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil]) {
        connectedToInternet = YES;
    }
    if (connectedToInternet)
    NSLog(@"We Have Internet!");
    
    [request release];
    [url release];
    return connectedToInternet;
}
- (void)checkForInternetAccess:(id)sender{
	//start dispatch
	dispatch_queue_t queueA, queueTar;
	queueA = dispatch_queue_create("com.bluehawk.axiom.cInternet", NULL);
	queueTar = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	dispatch_set_target_queue(queueTar, queueA);
	
	dispatch_async(queueA, ^{
        if ([AxiomAppDelegate isDataSourceAvailable]) {
            /*UpdateManager *u = [[UpdateManager alloc] init];
             if ([u isUpdateAvaliable]) {
             NSLog(@"Axiom - Found an update!");
             needsUpdate = YES;
             }
             else {
             NSLog(@"Axiom - No New updates");
             needsUpdate = NO;
             }
             
             [u release];*/
            
            /*NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com/"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
             NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
             [theConnection autorelease];*/
            dispatch_async(dispatch_get_main_queue(), ^{
                [internetPic setImage:[NSImage imageNamed:@"internet_ok.png"]];
            });
            NSLog(@"Axiom - We have internet connection!");
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [internetPic setImage:[NSImage imageNamed:@"internet_bad.png"]];
            });
            NSLog(@"Axiom - No Data source!");
        }
	});
    
    dispatch_release(queueTar);
    dispatch_release(queueA);
    
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	[internetPic setImage:[NSImage imageNamed:@"internet_ok.png"]];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[internetPic setImage:[NSImage imageNamed:@"internet_bad.png"]];	
}
#pragma mark End Internet Access

#pragma mark Start Misc Methods
-(void)updateDateTime:(id)ignore {
	//start dispatch
	dispatch_queue_t queueA, queueTar;
	queueA = dispatch_queue_create("com.bluehawk.axiom.cInternet", NULL);
	queueTar = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	dispatch_set_target_queue(queueTar, queueA);
	
	dispatch_async(queueA, ^{
        NSString			*path = [@"~/Library/Preferences/.GlobalPreferences.plist"
                                     stringByExpandingTildeInPath];
        NSDictionary		*prefs = [NSDictionary dictionaryWithContentsOfFile:path];
        NSString			*dateFormat = [[prefs objectForKey:@"AppleICUDateFormatStrings"]
                                           objectForKey:@"3"];
        NSString			*timeFormat = [[prefs objectForKey:@"AppleICUTimeFormatStrings"]
                                           objectForKey:@"3"];
        NSString			*date, *time;
        CFLocaleRef			locale = NULL;
        CFDateFormatterRef	formatter = NULL;
        
        //if (dateFormat == nil) {
        // Default if the user doesn't have anything configured.
        // 2 digit month, 2 digit day, 2 digit year.
        dateFormat = @"MMM. d, y";
        //}
        //if (timeFormat == nil) {
        // Default if the user doesn't have anything configured.
        // 24 hour 2 digit hour, 2 digit minute, and 2 digit seconds.
        timeFormat = @"h:mm a";
        //}
        
        locale = CFLocaleCopyCurrent();
        formatter = CFDateFormatterCreate(kCFAllocatorDefault, locale,
                                          kCFDateFormatterNoStyle,
                                          kCFDateFormatterNoStyle);
        
        CFDateFormatterSetFormat(formatter, (CFStringRef) dateFormat);
        date = (NSString *) CFDateFormatterCreateStringWithAbsoluteTime(
                                                                        kCFAllocatorDefault, formatter,
                                                                        CFAbsoluteTimeGetCurrent());
        
        CFDateFormatterSetFormat(formatter, (CFStringRef) timeFormat);
        time = (NSString *) CFDateFormatterCreateStringWithAbsoluteTime(
                                                                        kCFAllocatorDefault, formatter,
                                                                        CFAbsoluteTimeGetCurrent());
        
        CFRelease(locale);
        CFRelease(formatter);
        
		dispatch_async(dispatch_get_main_queue(), ^{
            [dateTextField setStringValue:[NSString stringWithFormat:@"%@\n%@", date, time]];
		});
        [date autorelease];
        [time autorelease];
	});
    
    dispatch_release(queueTar);
    dispatch_release(queueA);
}
-(void)checkForFullScreen{
	/*NSLog(@"Axiom - Front = %@\n", (self.iTunes.frontmost ? @"YES" : @"NO"));
     NSLog(@"Axiom - Full = %@\n", (self.iTunes.fullScreen ? @"YES" : @"NO"));
     if (self.iTunes.frontmost == YES) {
     
     if ([visualsTimer isValid]) {
     [visualsTimer invalidate];
     NSLog(@"Axiom - Visuals Timer Invalidated");
     }
     NSLog(@"Axiom - Bringing Axiom Back!");
     NSString* src1 = [NSString stringWithFormat:@"tell application \"System Events\"\n set visible of process \"iTunes\" to false\n end tell"];
     
     NSAppleScript* script1 = [[NSAppleScript alloc] initWithSource:src1];
     NSDictionary* error1;
     [script1 executeAndReturnError:&error1];
     [script1 autorelease];
     }*/
	
}


#pragma mark NSPopoverDelegate

// -------------------------------------------------------------------------------
// Invoked on the delegate when the NSPopoverWillShowNotification notification is sent.
// This method will also be invoked on the popover. 
// -------------------------------------------------------------------------------
- (void)popoverWillShow:(NSNotification *)notification
{
    
    
}

// -------------------------------------------------------------------------------
// Invoked on the delegate when the NSPopoverDidShowNotification notification is sent.
// This method will also be invoked on the popover. 
// -------------------------------------------------------------------------------
- (void)popoverDidShow:(NSNotification *)notification
{
    
}

// -------------------------------------------------------------------------------
// Invoked on the delegate when the NSPopoverWillCloseNotification notification is sent.
// This method will also be invoked on the popover. 
// -------------------------------------------------------------------------------
- (void)popoverWillClose:(NSNotification *)notification
{
    NSString *closeReason = [[notification userInfo] valueForKey:NSPopoverCloseReasonKey];
    if (closeReason)
    {
        // closeReason can be:
        //      NSPopoverCloseReasonStandard
        //      NSPopoverCloseReasonDetachToWindow
    }
}

// -------------------------------------------------------------------------------
// Invoked on the delegate when the NSPopoverDidCloseNotification notification is sent.
// This method will also be invoked on the popover. 
// -------------------------------------------------------------------------------
- (void)popoverDidClose:(NSNotification *)notification
{
    NSString *closeReason = [[notification userInfo] valueForKey:NSPopoverCloseReasonKey];
    if (closeReason)
    {
        // closeReason can be:
        //      NSPopoverCloseReasonStandard
        //      NSPopoverCloseReasonDetachToWindow
    }
    
    [playlistPopover release];
    playlistPopover = nil;
}



-(void)fireTimerForCheck{
	//visualsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkForFullScreen) userInfo:nil repeats:YES];
}

-(void)checkForDropBoxSync{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *dbPath = @"/Applications/Dropbox.app";
    NSString *dbDocPath = @"~/Dropbox";
    dbDocPath = [dbDocPath stringByExpandingTildeInPath];
    
    if ([manager fileExistsAtPath:dbPath]) {
        if ([manager fileExistsAtPath:dbDocPath isDirectory:YES]) {
            hasDropbox = YES;
            //perform folder setup here
        }
    }
}

+(BOOL)checkForReceipt{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString * pathToReceipt = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/_MASReceipt/receipt"];
    NSString *pathToOverride = [NSString stringWithFormat:@"/usr/bin/2c5d94dd609855f43c21c46744afec3d/f17aaabc20bfe045075927934fed52d2.zip"];
	// this example is not a bundle so it wont work here.
	
	[pathToReceipt retain];
	//NSLog(@"Path - %@",pathToReceipt);
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:pathToOverride]){
        NSLog(@"Axiom - Has override license");
        return YES;
    }
    
	if (!validateReceiptAtPath(pathToReceipt)){
        NSLog(@"Axiom - License Not Found!");
        //exit(173);
        return NO;
	}
	else {
		NSLog(@"Axiom - Has license from MAS.");
        return YES;
	}
    [pool release];
}

-(void)exitNoLicense{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://bit.ly/a7oybN"]];
    exit(173);
}

-(void)setActivationState{
    NSLog(@"Axiom - Checking for receipt");
    BOOL b = [AxiomAppDelegate checkForReceipt];
    activated = b;
}
#pragma mark End Misc Methods



#pragma mark Start AppleScript Utilities 
- (NSAppleEventDescriptor *) runWithSource:(NSString*)source andReturnError: (NSDictionary **) error {
    NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:source] retain];
    NSAppleEventDescriptor  *res = [script executeAndReturnError:error];
    
    [script release];
    
    return res;
}
#pragma mark End AppleScript Utilities

-(void) dealloc{
	
    [prevTrackScript release];
    [playScript release];
    [pauseScript release];
    [nextTrackScript release];
    [shuffleOnScript release];
    [shuffleOffScript release];
    [repeatAllScript release];
    [repeatOneScript release];
    [repeatOffScript release];
    [playerInfoScript release];
    [trackInfoScript release];
    [playlistsScript release];
    [currentPlaylistScript release];
    [_startupPlayer release];
	
	[super dealloc];
}

@end


