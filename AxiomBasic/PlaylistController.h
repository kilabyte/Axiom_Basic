//
//  PlaylistController.h
//  AxiomBasic
//
//  Created by Dave Sferra on 11-06-10.
//  Copyright 2011 Blue Hawk Solutions inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AxiomAppDelegate.h"
#import "iTunes.h"

@class AxiomAppDelegate;

@interface PlaylistController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>{
    NSString *playlistsScript;
    NSString *playerInfoScript;
    NSString *trackInfoScript;
    NSString *currentPlaylistNameScript;
    NSString *currentPlaylistScript;
    
    AxiomAppDelegate *appDelegate;
    
    int playlistNumber;
    
    BOOL isChecking;
    
    IBOutlet NSArrayController *sourceList;
    
    IBOutlet NSTableView *_tableView;
    IBOutlet NSScrollView *_scrollView;
    NSMutableArray *playlistArray;
    int scrollNumber;
}
    
@property (nonatomic, retain) NSMutableArray *playlistArray;

-(IBAction) tableRowClicked:(id)sender;
-(IBAction)upArrow:(id)sender;
-(IBAction)downArrow:(id)sender;
-(void)updateSourceList:(id)arg;
-(IBAction)clickPlaylist:(id)sender;
- (NSAppleEventDescriptor *) runWithSource:(NSString*)source andReturnError: (NSDictionary **) error;
@end
