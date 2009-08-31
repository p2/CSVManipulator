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
@synthesize headerCheckbox;
@synthesize headerTextfield;


- (id) init
{
	self = [super init];
	if (nil != self) {
		self.headerCheckbox = [[[NSButtonCell alloc] init] autorelease];
		[headerCheckbox setButtonType:NSSwitchButton];
		[headerCheckbox setControlSize:NSSmallControlSize];
		
		self.headerTextfield = [[[NSTextFieldCell alloc] init] autorelease];
		[headerTextfield setTextColor:[NSColor blackColor]];
	}
	
	return self;
}

- (void) dealloc
{
	self.headerCheckbox = nil;
	self.headerTextfield = nil;
	
	[super dealloc];
}

- (id) copyWithZone:(NSZone*)zone
{
	DataTableHeaderCell *cell = (DataTableHeaderCell *)[super copyWithZone:zone];
	
	cell->headerCheckbox = nil;
	cell.headerCheckbox = [headerCheckbox copyWithZone:zone];
	cell->headerTextfield = nil;
	cell.headerTextfield = [headerTextfield copyWithZone:zone];
	
	return cell;
}
#pragma mark -



#pragma mark KVC Overrides
- (NSString *) stringValue
{
	return [headerTextfield stringValue];
}
- (void) setStringValue:(NSString *)newString
{
	[headerTextfield setStringValue:newString];
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
	[headerCheckbox setState:(self.isChecked) ? 1 : 0];
	
	// rects and cells
	NSRect buttonFrame = cellFrame;
	buttonFrame.size.width = 20.0;
	
	NSRect sortIndicator = [self sortIndicatorRectForBounds:cellFrame];
	
	NSRect textFrame;
	textFrame = cellFrame;
	textFrame.origin.x += 20;
	textFrame.size.width -= 20 + sortIndicator.size.width;
	
	// draw the background, the checkbox and the text
	[super drawWithFrame:cellFrame inView:controlView];
	[headerCheckbox drawWithFrame:buttonFrame inView:controlView];
	[headerTextfield drawWithFrame:textFrame inView:controlView];
}

- (void) highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self setHighlighted:flag];
	[self drawWithFrame:cellFrame inView:controlView];
}



@end
