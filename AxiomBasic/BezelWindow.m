//
//  BezelWindow.m
//  Bezel
//

#import "BezelWindow.h"

//  The BezelWindow class makes a normal NSWindow transparent,
//  and disables the shadow. The BezelBox class actually draws the
//  rounded rectangle.

@implementation BezelWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
{
	//  Use NSBorderlessWindowMask, which hides the window's title:
	return [super initWithContentRect:contentRect styleMask:
		NSBorderlessWindowMask backing:bufferingType defer:flag];
}

// In order to receive key events
- (BOOL) canBecomeKeyWindow
{
  return YES;
}

- (void)awakeFromNib
{
	[self setOpaque:NO];											//  Enables transparency.
	[self setBackgroundColor:[NSColor clearColor]];		//  Use a clear background color.
	[self setHasShadow:NO];										//  Disable the shadow.
	
	[self setLevel:NSFloatingWindowLevel];					//  Float above other windows.
	//[self center];													//  Center on the screen.
}

@end
