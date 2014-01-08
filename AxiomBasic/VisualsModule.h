
#import "AxiomAppDelegate.h"
#import <Cocoa/Cocoa.h>


@interface VisualsModule: NSView {
	IBOutlet QCView *vView;
	BOOL isShowing;
}

- (void)visualInit;
- (IBAction)visualClick:(id)sender;



@end
