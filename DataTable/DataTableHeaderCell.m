//
//  DataTableHeaderCell.m
//  check
//
//  Created by Pascal Pfiffner on 04.03.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DataTableHeaderCell.h"


@implementation DataTableHeaderCell

@synthesize checked;


- (id) init
{
	self = [super init];
	if (nil != self) {
		checkbox = [[NSButtonCell alloc] init];
		[checkbox setButtonType:NSSwitchButton];
		[checkbox setControlSize:NSSmallControlSize];
		
		textfield = [[NSTextFieldCell alloc] init];
		[textfield setTextColor:[NSColor blackColor]];
	}
	
	return self;
}

- (void) dealloc
{
	[checkbox release];
	[textfield release];
	
	[super dealloc];
}

- (id) copyWithZone:(NSZone*)zone
{
	DataTableHeaderCell *cell = (DataTableHeaderCell *)[super copyWithZone:zone];
	//cell.checkbox = checkbox;
	return cell;
}
#pragma mark -



#pragma mark KVC
- (NSButtonCell *) checkbox
{
	return checkbox;
}
#pragma mark -



#pragma mark Mouse Tracking
/*
- (BOOL) startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
	NSLog(@"start");
}

- (void) stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
	NSLog(@"1");
	// if the mouse didn't move and we've got a mouseIsUp, do this
	if(CGPointEqualToPoint(NSPointToCGPoint(lastPoint), NSPointToCGPoint(stopPoint)) && flag) {
		NSLog(@"view: %@", controlView);
	}
	else {
		[super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];
	}
}
//	*/
#pragma mark -



#pragma mark Drawing
- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
	NSString *title = [self stringValue];
	[textfield setStringValue:title];
	
	[checkbox setState:(self.isChecked) ? 1 : 0];
	
	// rects and cells
	NSRect buttonFrame = cellFrame;
	buttonFrame.size.width = 20.0;
	
	NSRect sortIndicator = [self sortIndicatorRectForBounds:cellFrame];
	
	NSRect textFrame;
	textFrame = cellFrame;
	textFrame.origin.x += 20;
	textFrame.size.width -= 20 + sortIndicator.size.width;
	
	// no background
	[self setStringValue:@""];
	
	// draw the background, the checkbox and the text
	[super drawWithFrame:cellFrame inView:controlView];
	[checkbox drawWithFrame:buttonFrame inView:controlView];
	[textfield drawWithFrame:textFrame inView:controlView];
	
	// and set the title
	[self setStringValue:title];
}

- (void) highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSString *title = [self stringValue];
	[textfield setStringValue:title];
	[self setHighlighted:flag];
	
	[checkbox setState:(self.isChecked) ? 1 : 0];
	
	// rects and cells
	NSRect buttonFrame = cellFrame;
	buttonFrame.size.width = 20.0;
	
	NSRect sortIndicator = [self sortIndicatorRectForBounds:cellFrame];
	
	NSRect textFrame;
	textFrame = cellFrame;
	textFrame.origin.x += 20;
	textFrame.size.width -= 20 + sortIndicator.size.width;
	
	// no background
	[self setStringValue: @""];

	// draw the background, the checkbox and the text
	[super highlight:flag withFrame:cellFrame inView:controlView];
	[checkbox drawWithFrame:buttonFrame inView:controlView];
	[textfield drawWithFrame:textFrame inView:controlView];
	
	// set the title
	[self setStringValue:title];
}



@end
