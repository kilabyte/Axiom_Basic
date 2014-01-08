

#import <Cocoa/Cocoa.h>
#import "AxiomAppDelegate.h"

@interface AxiomAppDelegate (WindowAnimations) 

-(IBAction)animateWindowOutOfView:(NSWindow *)theWindow toDirection:(NSString *)direction;
-(IBAction)animateWindowIntoView:(NSWindow *)theWindow fromDirection:(NSString *)direction;

@end
