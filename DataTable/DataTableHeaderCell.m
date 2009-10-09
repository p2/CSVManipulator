//
//  DataTableHeaderCell.m
//  check
//
//  Created by Pascal Pfiffner on 04.03.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DataTableHeaderCell.h"


@implementation DataTableHeaderCell

@synthesize showsCheckbox;
@synthesize checked;
@synthesize headerCheckbox;
@synthesize headerTextfield;


- (id) init
{
	self = [super init];
	if (nil != self) {
		showsCheckbox = YES;
		sortPriority = 1;
		
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

- (BOOL) isChecked
{
	return (NSOnState == [headerCheckbox state]);
}
- (void) setChecked:(BOOL)flag
{
	[headerCheckbox setState:(flag ? NSOnState : NSOffState)];
}
#pragma mark -



#pragma mark Mouse and state tracking
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

-(void) setSortAscending:(BOOL)ascending priority:(NSUInteger)priority
{
	sortAscending = ascending;
	sortPriority = priority;
	
	[(NSControl *)[self controlView] updateCell:self];
}
#pragma mark -



#pragma mark Drawing
- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
	// get appropriate gradient colors
	//[super drawWithFrame:cellFrame inView:controlView];
	// TODO: Put this outside of drawWithFrame:
	NSColor *topColor, *bottomColor;
	if (NSOnState == [self state]) {										// being clicked on
		topColor = [NSColor colorWithDeviceWhite:0.74 alpha:1.0];
		bottomColor = [NSColor colorWithDeviceWhite:0.62 alpha:1.0];
	}
	else if (0 == sortPriority) {											// active sorting column
		NSColor *selectedColor = [NSColor selectedTextBackgroundColor];
		topColor = [selectedColor blendedColorWithFraction:0.1 ofColor:[NSColor whiteColor]];
		bottomColor = [selectedColor blendedColorWithFraction:0.1 ofColor:[NSColor blackColor]];
	}
	else {																	// idle
		topColor = [NSColor colorWithDeviceWhite:0.86 alpha:1.0];
		bottomColor = [NSColor colorWithDeviceWhite:0.74 alpha:1.0];
	}
	
	// create and draw the gradient
	const CGFloat locations[2] = { 0.0, 1.0 };
	NSArray *color_array = [NSArray arrayWithObjects:topColor, bottomColor, nil];
	NSGradient *gradient = [[NSGradient alloc] initWithColors:color_array atLocations:locations colorSpace:[(NSColor *)[color_array objectAtIndex:0] colorSpace]];
	[gradient drawInRect:cellFrame angle:90.0];
	
	// draw the divider
	[[NSColor grayColor] set];
	NSRect dividerRect = NSMakeRect(cellFrame.origin.x + cellFrame.size.width - 1.0, 0.0, 1.0, cellFrame.size.height);
	NSRectFill(dividerRect);
	
	// draw interior
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void) highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[self setHighlighted:flag];
	[self drawWithFrame:cellFrame inView:controlView];
}

- (void) drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	// rects and cells
	NSRect sortIndicator = [self sortIndicatorRectForBounds:cellFrame];
	
	NSRect textFrame;
	textFrame = cellFrame;
	
	// draw
	if (showsCheckbox) {
		NSRect buttonFrame = cellFrame;
		buttonFrame.size.width = 20.0;
		[headerCheckbox drawWithFrame:buttonFrame inView:controlView];
		
		textFrame.origin.x += 20;
		textFrame.size.width -= 20 + sortIndicator.size.width;
	}
	[headerTextfield drawWithFrame:textFrame inView:controlView];
	
	[self drawSortIndicatorWithFrame:cellFrame inView:controlView ascending:sortAscending priority:sortPriority];
}


@end
