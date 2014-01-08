//
//  BorderlessWindow.m
//


#import "BorderlessWindow.h"

//  The BorderlessWindow class makes a normal NSWindow borderless

@implementation BorderlessWindow



- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation screen:(NSScreen *)screen{
    
    return [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:deferCreation screen:screen];
}

// In order to receive key events
- (BOOL) canBecomeKeyWindow { return YES; }
- (BOOL) acceptsFirstResponder { return YES; }
- (BOOL) becomeFirstResponder { return YES; }
- (BOOL) resignFirstResponder { return YES; }
- (BOOL) _hasActiveControls{return YES;}

- (void)awakeFromNib
{
	[self setBackgroundColor:[NSColor blackColor]];	

	//NSRect theScreenFrame = [[NSScreen mainScreen] frame];
	//[self setFrame:theScreenFrame display:YES animate:NO];
	[self setHasShadow:NO];										//  Disable the shadow.

	//[self center];													//  Center on the screen.
}



@end
