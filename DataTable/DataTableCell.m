//
//  DataTableCell.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 09.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DataTableCell.h"


@implementation DataTableCell


- (id) init
{
	self = [super init];
	if (self) {
		[self setEditable:YES];
	}
	return self;
}

+ (DataTableCell *) cell
{
	return [[[DataTableCell alloc] init] autorelease];
}
#pragma mark -



#pragma mark Drawing
- (void) drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	// no value - draw a placeholder
	if (nil == [self objectValue]) {
		NSColor *fgColor = [NSColor lightGrayColor];
		[fgColor setFill];
		CGFloat circleRadius = 1.5;
		NSRect ovalRect = NSMakeRect(
									 (cellFrame.origin.x + (cellFrame.size.width / 2) - circleRadius),		// x
									 (cellFrame.origin.y + (cellFrame.size.height / 2) - circleRadius),		// y
									 2 * circleRadius,														// width
									 2 * circleRadius														// height
									 );
		NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:ovalRect];
		[circlePath fill];
	}
	
	// got a value
	else {
		[super drawInteriorWithFrame:cellFrame inView:controlView];
	}
}


@end
