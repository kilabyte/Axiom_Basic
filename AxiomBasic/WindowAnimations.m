

#import "WindowAnimations.h"


@implementation AxiomAppDelegate (WindowAnimations)

#pragma mark -
#pragma mark Window Animatioins

//
// Please note, I've included a MiscWindowAnimations.m that has some other window animations
// that I was playing around with.  They actually look more FrontRow-ish, but they are kludgy,
// and I think that these simpler ones work better
//
-(IBAction)animateWindowOutOfView:(NSWindow *)theWindow toDirection:(NSString *)direction
{
	if ([direction isEqualToString:@"bottom"]) {
	
		NSRect theScreenFrame = [theWindow frame];
		theScreenFrame.origin.y = 0 - theScreenFrame.size.height;
		[theWindow setFrame:theScreenFrame display:YES animate:YES];
		[theWindow orderOut:self];
	}
	if ([direction isEqualToString:@"top"]) {
	
		NSRect theScreenFrame = [theWindow frame];
		theScreenFrame.origin.y = theScreenFrame.size.height;
		[theWindow setFrame:theScreenFrame display:YES animate:YES];
		[theWindow orderOut:self];
	}
}

-(IBAction)animateWindowIntoView:(NSWindow *)theWindow fromDirection:(NSString *)direction
{
	
	if ([direction isEqualToString:@"top"]) {
		[theWindow orderOut:self];
	
		NSRect theScreenFrame = [theWindow frame];
		NSPoint theOrigin = theScreenFrame.origin;
		NSSize theSize = theScreenFrame.size;
	
		theOrigin.y = theSize.height;
		theOrigin.x = 0;
		theScreenFrame.origin = theOrigin;
	
		[theWindow setFrame:theScreenFrame display:NO animate:NO];
	
		theOrigin.y = 0;
		theScreenFrame.origin = theOrigin;
	
		[theWindow makeKeyAndOrderFront:self];
		[theWindow setFrame:theScreenFrame display:YES animate:YES];
	}
	
	if ([direction isEqualToString:@"right"])  {
		[theWindow orderOut:self];
	
		NSRect theScreenFrame = [theWindow frame];
		NSPoint theOrigin = theScreenFrame.origin;
		NSSize theSize = theScreenFrame.size;
	
		theOrigin.x = theSize.width;
		theOrigin.y = 0;
		theScreenFrame.origin = theOrigin;
	
		[theWindow setFrame:theScreenFrame display:NO animate:NO];
	
		//theOrigin.x = 0;
		//theScreenFrame.origin = theOrigin;
	
		[theWindow makeKeyAndOrderFront:self];
		[theWindow setFrame:theScreenFrame display:YES animate:YES];
	}
	
	if ([direction isEqualToString:@"left"])  {
		[theWindow orderOut:self];
	
		NSRect theScreenFrame = [theWindow frame];
		NSPoint theOrigin = theScreenFrame.origin;
		NSSize theSize = theScreenFrame.size;
	
		theOrigin.x = 0 - theSize.width;
		theOrigin.y = 0;
		theScreenFrame.origin = theOrigin;
	
		[theWindow setFrame:theScreenFrame display:NO animate:NO];
	
		theOrigin.x = 0;
		theScreenFrame.origin = theOrigin;
	
		[theWindow makeKeyAndOrderFront:self];
		[theWindow setFrame:theScreenFrame display:YES animate:YES];
	}
	
	if ([direction isEqualToString:@"bottom"])  {
		[theWindow orderOut:self];
	
		NSRect theScreenFrame = [theWindow frame];
		NSPoint theOrigin = theScreenFrame.origin;
		NSSize theSize = theScreenFrame.size;
	
		theOrigin.y = 0 - theSize.height;
		theOrigin.x = 0;
		theScreenFrame.origin = theOrigin;
	
		[theWindow setFrame:theScreenFrame display:NO animate:NO];
	
		theOrigin.y = 0;
		theScreenFrame.origin = theOrigin;
	
		[theWindow makeKeyAndOrderFront:self];
		[theWindow setFrame:theScreenFrame display:YES animate:YES];
	}	
}

@end
