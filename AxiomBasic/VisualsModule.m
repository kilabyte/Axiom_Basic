

#import "VisualsModule.h"


@implementation VisualsModule




- (IBAction)visualClick:(id)sender{

}

-(void)viewWillDraw{
	if (isShowing == NO) {
		[self visualInit];
		isShowing = YES;
	}
	
}


-(void)viewDidHide{
	isShowing = NO;
	[vView stopRendering];
}

- (void)visualInit
{	
	// Our list of all of the Quartz composer files I'm including
 	NSMutableArray *visualsArray = [NSMutableArray array];
    AxiomAppDelegate *a;
    a = AppDelegate;
    [visualsArray addObject:@"BinaryEarth"];
	[visualsArray addObject:@"SoundstreamiTunes"];

												
	// Display the screen, load the file, and play it
	[vView loadCompositionFromFile: [[NSBundle mainBundle] pathForResource:[visualsArray objectAtIndex:a.visNumber] ofType:@"qtz"]];
	
	[vView startRendering];
	
}

@end
