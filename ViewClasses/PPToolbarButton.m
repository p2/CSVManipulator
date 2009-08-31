//
//  PPToolbarButton.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 28.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PPToolbarButton.h"
#import "PPToolbarButtonCell.h"


@implementation PPToolbarButton

@dynamic buttonType;
@dynamic borderWidths;
@dynamic borderColor, borderHighlightColor, borderActiveColor, borderDisabledColor;
@dynamic baseColor, highlightColor, activeColor, disabledColor;


+ (Class) cellClass
{
	return [PPToolbarButtonCell class];
}

- (id) initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self setDefaults];
	}
	return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		NSButtonCell *oldCell = [self cell];
		
		// we need to throw away the NSButtonCell that IB created and replace it with the right one
		if (![[oldCell class] isKindOfClass:[[self class] cellClass]]) {
			PPToolbarButtonCell *newCell = [[PPToolbarButtonCell alloc] initTextCell:[oldCell title]];
			newCell.button = self;
			
			// copy the 17 NSCellAttribute-s to the new cell
			NSInteger i;
			for (i = 0; i < 17; i++) {
				[newCell setCellAttribute:i to:[oldCell cellAttribute:i]];
			}
			
			[self setCell:newCell];
			[newCell release];
		}
		
		// set defaults
		[self setDefaults];
	}
	return self;
}

- (void) setDefaults
{
	NSNumber *default_border_width = [NSNumber numberWithInt:1.0];
	self.borderWidths = [NSArray arrayWithObjects:default_border_width, default_border_width, [NSNull null], default_border_width, nil];
	
	self.borderColor = self.borderHighlightColor = self.borderActiveColor = self.borderDisabledColor = [NSColor grayColor];
	
	self.baseColor = [NSColor whiteColor];
	self.highlightColor = [NSColor colorWithDeviceWhite:0.8 alpha:1.0];
	self.activeColor = [NSColor selectedTextBackgroundColor];
	self.disabledColor = [NSColor whiteColor];
}

- (void) dealloc
{
	[super dealloc];
}
#pragma mark -



#pragma mark KVC
- (NSButtonType) buttonType
{
	return buttonType;
}
- (void) setButtonType:(NSButtonType)newType
{
	//NSLog(@"set to: %i", buttonType);
	if (newType != buttonType) {
		[super setButtonType:newType];
		buttonType = newType;
	}
}

// Border width array
- (NSArray *) borderWidths
{
	return [[self cell] borderWidths];
}
- (void) setBorderWidths:(NSArray *)newWidths
{
	[[self cell] setBorderWidths:newWidths];
}

// Border colors
- (NSColor *) borderColor
{
	return [[self cell] borderColor];
}
- (void) setBorderColor:(NSColor *)newColor
{
	[[self cell] setBorderColor:newColor];
}

- (NSColor *) borderHighlightColor
{
	return [[self cell] borderHighlightColor];
}
- (void) setBorderHighlightColor:(NSColor *)newColor
{
	[[self cell] setBorderHighlightColor:newColor];
}

- (NSColor *) borderActiveColor
{
	return [[self cell] borderActiveColor];
}
- (void) setBorderActiveColor:(NSColor *)newColor
{
	[[self cell] setBorderActiveColor:newColor];
}

- (NSColor *) borderDisabledColor
{
	return [[self cell] borderDisabledColor];
}
- (void) setBorderDisabledColor:(NSColor *)newColor
{
	[[self cell] setBorderDisabledColor:newColor];
}

// Background colors
- (NSColor *) baseColor
{
	return [[self cell] baseColor];
}
- (void) setBaseColor:(NSColor *)newColor
{
	[[self cell] setBaseColor:newColor];
}

- (NSColor *) highlightColor
{
	return [[self cell] highlightColor];
}
- (void) setHighlightColor:(NSColor *)newColor
{
	[[self cell] setHighlightColor:newColor];
}

- (NSColor *) activeColor
{
	return [[self cell] activeColor];
}
- (void) setActiveColor:(NSColor *)newColor
{
	[[self cell] setActiveColor:newColor];
}

- (NSColor *) disabledColor
{
	return [[self cell] disabledColor];
}
- (void) setDisabledColor:(NSColor *)newColor
{
	[[self cell] setDisabledColor:newColor];
}
#pragma mark -



#pragma mark Actions



@end
