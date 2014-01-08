//
//  AxiomAppDelegate.h
//  Silos
//


#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import "UpdateManager.h"
#import "CustomButton.h"
#import "iTunes.h"
#import <Quartz/Quartz.h>
#import "PlaylistController.h"
#import <AVFoundation/AVFoundation.h>

@class WindowAnimations;
@class iTunesApplication;
@class iTunesPlaylist;
@class PlaylistController;


#define AppDelegate	(AxiomAppDelegate *)[[NSApplication sharedApplication] delegate]

@interface AxiomAppDelegate : NSObject  <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource, NSWindowDelegate, NSPopoverDelegate>{
    
    NSWindow *window;
    
    AVAudioPlayer *_startupPlayer;
	
	IBOutlet NSArrayController *sourceList;
	
    IBOutlet NSView*            rootView;
    
    NSPopover *playlistPopover;
    
    IBOutlet PlaylistController *pController;
    NSMatrix *popoverPosition;
    
	IBOutlet NSProgressIndicator *initialLoading;
	IBOutlet NSTextField *initialLoadingText;
	
	int playlistNumber;
	NSString *selectedPlaylistName;
    iTunesApplication* iTunes;
    
    IBOutlet NSTextField* disclaimerTF;
    
	NSTimer *loadingTimer;
	
	IBOutlet NSButton *albumArtImage;
	
    IBOutlet NSTextField* songTitle;
    IBOutlet NSTextField* songTime;
    
    IBOutlet NSButton* volumeButton;
    IBOutlet NSButton* prevButton;
    IBOutlet NSButton* nextButton;
    IBOutlet NSButton* playPauseButton;
    
	IBOutlet NSTextField *versionText;
    
    IBOutlet NSButton* agreeButton;
    
    IBOutlet NSButton* quitButton;
    
    IBOutlet NSScrollView* tableScroll;
    
    NSTimer* updateDisplayTimer;
    
    IBOutlet NSApplication* theApp;
    
    IBOutlet NSImageView* hawk;
    IBOutlet NSImageView* menuBG;    
    
	IBOutlet NSImageView* internetPic;
    IBOutlet NSImageView* progressBack;
    IBOutlet NSImageView* progressFore;
    
    IBOutlet NSSlider* volumeSlider;
    
    int savedItunesVolume;
    
    IBOutlet NSButton *ejectButton;
    NSMutableArray* tracksArray;
    
    IBOutlet NSTableView* table;
    
	IBOutlet NSTextField *currentTrackLabel;
    
	
	NSTimer *checkforInternet;
	NSTimer *checkForLicenseTimer;
    
    IBOutlet NSButton* menuButton11;
    IBOutlet NSButton* menuButton12;
    IBOutlet NSButton* menuButton13; 
    IBOutlet NSButton* menuButton21;
    IBOutlet NSButton* menuButton22;
    IBOutlet NSButton* menuButton23;
    
	IBOutlet NSButton *playListSelectButton;
	IBOutlet NSTextField *playListName;
	IBOutlet NSTextField *dateTextField;
	
	IBOutlet NSButton* playListButton;
	IBOutlet NSButton* leftNavButton;
	IBOutlet NSButton* rightNavButton;
	
	IBOutlet NSButton *shuffleButton;
	IBOutlet NSButton *repeatButton;
	
	int currentTrackIndexField;
    NSString     *trackCountField;
    
	BOOL shouldShuffle;
	BOOL shouldRepeat;
	BOOL usingBigScreen;
    
    NSString *isCelcius;
    
    BOOL hasDropbox;
	
	
	
    IBOutlet NSScroller* verticalScroller;
    
    BOOL iTunesShouldBePlaying;
    int updateCountDown;
    
	
	NSString *internetAccess;
	BOOL _isDataSourceAvailable;
	
    
    IBOutlet NSTextField* settingsLabel;
	
	int currentScrollIndex;
	int oldScrollIndex;
	
	IBOutlet NSButton *plNext;
	IBOutlet NSButton *plPrev;
	
	NSTimer *visualsTimer;
	
    NSString                   *prevTrackScript;
    NSString                   *playScript;
    NSString                   *pauseScript;
    NSString                   *nextTrackScript;
    NSString                   *shuffleOnScript;
    NSString                   *shuffleOffScript;
    NSString                   *repeatAllScript;
    NSString                   *repeatOneScript;
    NSString                   *repeatOffScript;
    NSString                   *playerInfoScript;
    NSString                   *trackInfoScript;
    NSString                   *playlistsScript;
    NSString                   *currentPlaylistScript;
    NSString                   *currentPlaylistNameScript;
    
	BOOL changedSong;
	BOOL didPushUp;
	BOOL didPushDown;
	
	NSMutableArray *playlistArray;
    
	IBOutlet QCView *vViewSmall;
	
	IBOutlet NSView *initialView;
	IBOutlet NSView *mainContentView;
	
	IBOutlet NSView *disclaimerView;
	IBOutlet NSView *menuView;
	IBOutlet NSView *musicView;
	IBOutlet NSView *webView;
	IBOutlet NSView *weatherView;
	IBOutlet NSView *updateView;
	IBOutlet NSView *settingsView;
	IBOutlet NSView *volumeView;
	IBOutlet NSView *visualsView;
	IBOutlet NSView *lockedView;
	IBOutlet NSView *musicVisualsView;
	
	BOOL _userAgreed;
	
     CGDisplayFadeReservationToken    token;
	BOOL _menuShowing;
	BOOL isShowingVolumeView;
	BOOL isShowingMusicView;
	BOOL isShowingWebView;
	BOOL isShowingWeatherView;
	BOOL isShowingUpdateView;
	BOOL isShowingSettingsView;
	BOOL isShowingVisuals;
	BOOL _isFullScreen;
	
	BOOL needsUpdate;
	
	BOOL appLocked;
	
	
	IBOutlet NSImageView *visImage;
	IBOutlet NSTextField *visTitle;
	IBOutlet NSTextField *visArtist;
	
	NSString *tempCompareTitle;
	NSString *tempCompareArtist;
	NSInteger licenseCount;
	
	
	
	BOOL timesUp;
	
	BOOL activated;
    
    BOOL setupMusic;
	
	NSString *postalCode;
	NSString *weatherCity;
	NSString *dayF1;
    
    BOOL closePL;
    int visNumber;
    
    NSTimer *volumeTimer;
}

@property (assign)BOOL menuShowing;
@property (assign)BOOL userAgreed;
@property (assign)BOOL activated;
@property(nonatomic, assign)int visNumber;
@property(nonatomic, assign)int playlistNumber;
@property(nonatomic, assign)BOOL closePL;
@property(nonatomic,retain)NSMutableArray *tracksArray;
@property(nonatomic,retain)NSString *trackCountField;
@property(nonatomic, retain)NSMutableArray *playlistArray;
@property(nonatomic,assign)int currentTrackIndexField;
@property (assign) IBOutlet NSWindow *window;
@property(assign) IBOutlet NSView *rootView;
@property(nonatomic,retain) NSView *mainContentView;
@property(nonatomic, retain) NSString *postalCode;
@property(nonatomic, retain) 	NSString *weatherCity;
@property(nonatomic,retain) 	NSString *dayF1;
@property(nonatomic,assign)	BOOL isShowingWeatherView;
@property(nonatomic,retain) NSPopover *playlistPopover;
@property (retain,nonatomic) iTunesApplication* iTunes;
@property(nonatomic, retain)NSString *isCelcius;

-(void)setActivationState;
-(void)checkForLicense;
-(void)setMainTitle:(NSString *)s;
-(IBAction)toggleRepeat:(id)sender;
+(BOOL)checkForReceipt;
-(BOOL)hasInternet;
-(IBAction)toggleShuffle:(id)sender;
-(CGFloat)contentHeight;
-(IBAction)changeVis:(id)sender;
-(void)toggleFullScreenMode;
-(IBAction)cyclePlaylistsBack:(id)sender andPlaylistNumber:(NSInteger)playlistNum;
-(IBAction)menuButton11:(id)sender;
-(IBAction)menuButton12:(id)sender;
-(void)gotoMenu:(NSString*)menuName;
-(IBAction)menuButton13:(id)sender;
-(void)clickTimerLicense;
-(IBAction)refreshPlayList:(id)sender;
-(void)setSmallVisWithNumber:(int)index;
-(IBAction)scrollToCurrentSong:(id)sender;
-(IBAction)showVisuals:(id)sender;
-(void)updateDateTime:(id)ignore;
-(void)resetPlaylists;
-(IBAction)menuButton21:(id)sender;
-(IBAction)menuButton22:(id)sender;
-(IBAction)menuButton23:(id)sender;
-(IBAction)clickPlaylist:(id)sender;
-(void)terminateApp;
-(IBAction)UpNavButton:(id)sender;
-(IBAction)DownNavButton:(id)sender;
-(IBAction)cyclePlaylists:(id)sender andPlaylistNumber:(NSInteger)playlistNum;
-(void)getNewTrackIndex;
-(IBAction) playPause:(id)sender;
-(void)fadeVolume:(NSString *)direction;
-(IBAction)next:(id)sender;
-(IBAction)prev:(id)sender;
-(IBAction)showVolume:(id)sender;
- (NSAppleEventDescriptor *) runWithSource:(NSString*)source andReturnError: (NSDictionary **) error;
-(IBAction) quit:(id)sender;
- (void)checkForInternetAccess:(id)sender;
-(IBAction) agree:(id)sender;
-(IBAction) tableRowClicked:(id)sender;
-(void)clearTracks;
+(NSString*)getSystemVersion;
- (IBAction)iTunesStuffWithListNumber:(int)number;
-(void)updateDisplay;
- (void) updateSourceList:(id) arg;
-(void)HideEverything:(BOOL)hide;
-(IBAction) sliderDidSomething:(id)sender;
- (void)setVolume_Itunes_Slider:(float)volume;
-(void)exitNoLicense;

- (IBAction)toggleFullscreen:(id)sender;

- (void)fadeOut;
- (void)fadeIn;


#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
+ (BOOL)isDataSourceAvailable;

@end
