//
//  BHSDialog.m
//  Food
//
//  Created by Dave Sferra on 2012-09-07.
//  Copyright (c) 2012 Blue Hawk Solutions inc. All rights reserved.
//

#import "BHSDialog.h"

@implementation BHSDialog
@synthesize dialogWindow, status, title, statusImage;

- (id)init
{
    self = [super init];
    if (self) {
        [NSBundle loadNibNamed:@"BHSDialog" owner:self];
    }
    return self;
}

-(void)awakeFromNib{
    [self.dialogWindow setFrameTopLeftPoint:NSMakePoint(500, 500)];
}

-(void)imageForEvent:(NSString *)isSuccess{
    if ([isSuccess isEqualToString:@"yes"]) {
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"success"]];
        [statusImage setImage:image];
        [image release];
    }
    else if([isSuccess isEqualToString:@"no"]){
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"error"]];
        [statusImage setImage:image];
        [image release];
    }
}
-(IBAction)close:(id)sender{
    [NSApp stopModal];
    [self.dialogWindow orderOut:self];
}


- (void)dealloc
{
    [dialogWindow release];
    [statusImage release];
    [title release];
    [status release];
    [super dealloc];
}

@end
