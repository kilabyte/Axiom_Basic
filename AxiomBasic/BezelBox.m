//
//  BezelBox.m
//  Bezel
//

#import "BezelBox.h"

//  BezelBox actually draws the rounded, black box. 
//  It should go inside of a BezelWindow.

@implementation BezelBox

- (void)drawRect:(NSRect)rect
{
	NSBezierPath *roundRectPath = [NSBezierPath bezierPath];
	
	float rectRadius = 40.0;
	NSRect boundsRect = NSInsetRect([self bounds], 
		rectRadius, rectRadius);
	
	[roundRectPath appendBezierPathWithArcWithCenter:
		NSMakePoint(NSMinX(boundsRect), NSMinY(boundsRect)) 
		radius:rectRadius startAngle:180.0 endAngle:270.0];
		
	[roundRectPath appendBezierPathWithArcWithCenter:
		NSMakePoint(NSMaxX(boundsRect), NSMinY(boundsRect)) 
		radius:rectRadius startAngle:270.0 endAngle:360.0];
		
	[roundRectPath appendBezierPathWithArcWithCenter:
		NSMakePoint(NSMaxX(boundsRect), NSMaxY(boundsRect)) 
		radius:rectRadius startAngle:0.0 endAngle:90.0];
		
	[roundRectPath appendBezierPathWithArcWithCenter:
		NSMakePoint(NSMinX(boundsRect), NSMaxY(boundsRect)) 
		radius:rectRadius startAngle:90.0 endAngle:180.0];
		
	[[NSColor colorWithDeviceWhite:0.0 alpha:0.90] set];
	[roundRectPath fill];
}

@end
