//
//  DataTableHeaderCell.m
//  check
//
//  Created by Pascal Pfiffner on 04.03.08.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import "DataTableHeaderCell.h"
#import "DataTableColumn.h"


@interface DataTableHeaderCell ()

- (void) checkboxAction:(NSView *)controlView;

@end



@implementation DataTableHeaderCell

@synthesize myColumn;
@synthesize showsCheckbox;
@synthesize checked;
@synthesize headerCheckbox;
@synthesize headerTextfield;


- (id) init
{
	self = [super init];
	if (nil != self) {
		showsCheckbox = YES;
		headerCheckboxRect = NSZeroRect;
		
		self.headerCheckbox = [[[NSButtonCell alloc] init] autorelease];
		[headerCheckbox setButtonType:NSSwitchButton];
		[headerCheckbox setControlSize:NSSmallControlSize];
		[headerCheckbox setTarget:self];
		[headerCheckbox setAction:@selector(checkboxAction:)];
		[headerCheckbox sendActionOn:NSLeftMouseUpMask];
		
		self.headerTextfield = [[[NSTextFieldCell alloc] init] autorelease];
		[headerTextfield setTextColor:[NSColor blackColor]];
	}
	
	return self;
}

- (void) dealloc
{
	self.myColumn = nil;
	self.headerCheckbox = nil;
	self.headerTextfield = nil;
	
	[super dealloc];
}

- (id) copyWithZone:(NSZone*)zone
{
	DataTableHeaderCell *cell = (DataTableHeaderCell *)[super copyWithZone:zone];
	
	cell.myColumn = nil;								// to avoid associating with the same column
	cell->showsCheckbox = showsCheckbox;
	cell->headerCheckbox = nil;
	cell.headerCheckbox = [[headerCheckbox copyWithZone:zone] autorelease];
	cell->headerCheckboxRect = headerCheckboxRect;
	cell.checked = NO;									// does not work...
	cell->headerTextfield = nil;
	cell.headerTextfield = [[headerTextfield copyWithZone:zone] autorelease];
	
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
	return checked;
}
- (void) setChecked:(BOOL)flag
{
	checked = flag;
	
	// adjust our checkbox
	if (headerCheckbox) {
		NSCellStateValue curState = headerCheckbox.state;
		NSCellStateValue newState = (flag ? NSOnState : NSOffState);
		if (curState != newState) {
			[headerCheckbox setState:newState];
		}
	}
	
	// tell our column
	if (myColumn) {
		myColumn.active = checked;
	}
}
#pragma mark -



#pragma mark Mouse and state tracking
- (NSUInteger) hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView
{
	// check if we hit the checkbox
	if (!NSEqualRects(headerCheckboxRect, NSZeroRect)) {
		NSPoint hit = [controlView convertPoint:[event locationInWindow] fromView:nil];
		if (hit.x > headerCheckboxRect.origin.x && hit.x < (headerCheckboxRect.origin.x + headerCheckboxRect.size.width)) {		// y will be hit anyway
			return NSCellHitTrackableArea;
		}
	}
	
	// no; return default
	return [super hitTestForEvent:event inRect:cellFrame ofView:controlView];
}

- (BOOL) trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
	// tell the checkbox to track, if we're currently inside her
	if (headerCheckbox && (NSCellHitTrackableArea & [headerCheckbox hitTestForEvent:theEvent inRect:cellFrame ofView:controlView])) {
		return [headerCheckbox trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:untilMouseUp];
	}
	return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:untilMouseUp];
}

- (void) checkboxAction:(NSView *)controlView
{
	self.checked = (NSOnState == headerCheckbox.state);
}
#pragma mark -



#pragma mark Drawing
- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
	// get appropriate gradient colors
	// TODO: Put this outside of drawWithFrame:
	NSColor *topColor, *bottomColor;
	
	if (NSOnState == [self state]) {											// being clicked on
		topColor = [NSColor colorWithDeviceWhite:0.72 alpha:1.0];
		bottomColor = [NSColor colorWithDeviceWhite:0.60 alpha:1.0];
	}
	else if ([[controlView window] isMainWindow]) {
		if (nil != myColumn && 0 == myColumn.sortPriority) {					// active sorting column
			NSColor *selectedColor = [NSColor selectedTextBackgroundColor];
			topColor = [selectedColor blendedColorWithFraction:0.1 ofColor:[NSColor whiteColor]];
			bottomColor = [selectedColor blendedColorWithFraction:0.1 ofColor:[NSColor blackColor]];
		}
		else {																	// idle
			topColor = [NSColor colorWithDeviceWhite:0.8 alpha:1.0];
			bottomColor = [NSColor colorWithDeviceWhite:0.67 alpha:1.0];
		}
	}
	else {																		// window in background
		topColor = [NSColor colorWithDeviceWhite:0.9 alpha:1.0];
		bottomColor = [NSColor colorWithDeviceWhite:0.82 alpha:1.0];
	}
	
	// create and draw the gradient
	const CGFloat locations[2] = { 0.0, 1.0 };
	NSArray *color_array = [NSArray arrayWithObjects:topColor, bottomColor, nil];
	NSGradient *gradient = [[[NSGradient alloc] initWithColors:color_array atLocations:locations colorSpace:[(NSColor *)[color_array objectAtIndex:0] colorSpace]] autorelease];
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
		[headerCheckbox setControlTint:([[controlView window] isMainWindow] ? NSDefaultControlTint : NSClearControlTint)];
		
		NSRect buttonFrame = cellFrame;
		buttonFrame.size.width = 20.0;
		[headerCheckbox drawWithFrame:buttonFrame inView:controlView];
		headerCheckboxRect = buttonFrame;
		
		textFrame.origin.x += 20;
		textFrame.size.width -= 20 + sortIndicator.size.width;
	}
	[headerTextfield drawWithFrame:textFrame inView:controlView];
	
	NSUInteger priority = (nil != myColumn) ? myColumn.sortPriority : 1;
	[self drawSortIndicatorWithFrame:cellFrame inView:controlView ascending:myColumn.sortAscending priority:priority];
}


@end
