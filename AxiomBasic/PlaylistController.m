//
//  PlaylistController.m
//  AxiomBasic
//
//  Created by Dave Sferra on 11-06-10.
//  Copyright 2011 Blue Hawk Solutions inc. All rights reserved.
//

#import "PlaylistController.h"

@implementation PlaylistController
@synthesize playlistArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        
    }
    
    return self;
}

-(void)awakeFromNib{
    // Initialization code here.
    appDelegate = AppDelegate;
    if (isChecking == NO) {
        self.title = @"Playlists";
        playlistArray = [[NSMutableArray alloc] init];
        iTunesSource *library = [[appDelegate.iTunes sources] objectAtIndex:0];
        SBElementArray* playLists = [library userPlaylists];
        
        NSArray *a = [[NSArray alloc] initWithArray:playLists];
        for (int d = 0; d < [a count]; d++) {
            iTunesLibraryPlaylist *i = [playLists objectAtIndex:d];
            if (i.name != nil) {
                [playlistArray addObject:i.name];
            }
        }

        
        
        isChecking = YES;
    }
}

-(void)viewWillDraw{

}

-(void)viewDidHide{
    isChecking = NO;
}



#pragma mark Start Music Table Delegate/Methods
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [playlistArray count];
}
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString* objVal = nil;
    NSString* identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"songTitle"] == YES)
    {
        objVal = [playlistArray objectAtIndex:row];
    }
    else 
    {
        objVal = @"Axiom ERROR - 42222";
    }
    
    return objVal;
    
}
-(void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    [cell setTextColor:[NSColor whiteColor]];
}
-(IBAction) tableRowClicked:(id)sender{
    int i = [_tableView selectedRow] + 1;
    appDelegate.playlistNumber = i;
	[appDelegate clickPlaylist:nil];
    [appDelegate.playlistPopover close];
    
}


#pragma mark Start AppleScript Utilities 
- (NSAppleEventDescriptor *) runWithSource:(NSString*)source andReturnError: (NSDictionary **) error {
    NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:source] retain];
    NSAppleEventDescriptor  *res = [script executeAndReturnError:error];
    
    [script release];
    
    return res;
}


-(IBAction)upArrow:(id)sender{
    playlistNumber -= 3;
    if (playlistNumber <= 0) {
        playlistNumber = 0;
    }
    [_tableView scrollRowToVisible:playlistNumber];
}

-(IBAction)downArrow:(id)sender{
    playlistNumber += 3;
    if (playlistNumber >= [playlistArray count]) {
        playlistNumber = [playlistArray count]-1;
    }
    [_tableView scrollRowToVisible:playlistNumber];
}


- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
