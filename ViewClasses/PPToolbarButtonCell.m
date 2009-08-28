//
//  PPToolbarButton.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 28.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PPToolbarButtonCell.h"
#import "PPToolbarButton.h"


@implementation PPToolbarButtonCell

@synthesize button;

@synthesize borderWidths;
@synthesize borderColor;
@synthesize borderHighlightColor;
@synthesize borderActiveColor;
@synthesize borderDisabledColor;
@dynamic baseColor;
@dynamic highlightColor;
@dynamic activeColor;
@dynamic disabledColor;

@synthesize baseColorsArray;
@synthesize highlightColorsArray;
@synthesize activeColorsArray;
@synthesize disabledColorsArray;



- (void) dealloc
{
	self.borderWidths = nil;
	self.borderColor = nil;
	self.borderHighlightColor = nil;
	self.borderActiveColor = nil;
	self.borderDisabledColor = nil;
	
	self.baseColor = nil;
	self.highlightColor = nil;
	self.activeColor = nil;
	self.disabledColor = nil;
	
	self.baseColorsArray = nil;
	self.highlightColorsArray = nil;
	self.activeColorsArray = nil;
	self.disabledColorsArray = nil;
	
	[super dealloc];
}
#pragma mark -



#pragma mark KVC
- (NSColor *) baseColor
{
	return baseColor;
}
- (void) setBaseColor:(NSColor *)newColor
{
	if (newColor != baseColor) {
		[baseColor release];
		baseColor = [newColor retain];
		
		// get color components to compose gradient colors
		if (nil != baseColor) {
			NSColor *white_color = [NSColor whiteColor];
			NSColor *black_color = [NSColor blackColor];
			
			self.baseColorsArray = [NSArray arrayWithObjects:
									[baseColor blendedColorWithFraction:0.4 ofColor:white_color],
									[baseColor blendedColorWithFraction:0.2 ofColor:white_color],
									[baseColor blendedColorWithFraction:0.1 ofColor:black_color],
									[baseColor blendedColorWithFraction:0.05 ofColor:white_color],
									[baseColor blendedColorWithFraction:0.05 ofColor:black_color],
									nil];
		}
	}
}

- (NSColor *) highlightColor
{
	return highlightColor;
}
- (void) setHighlightColor:(NSColor *)newColor
{
	if (newColor != highlightColor) {
		[highlightColor release];
		highlightColor = [newColor retain];
		
		// get color components to compose gradient colors
		if (nil != highlightColor) {
			NSColor *white_color = [NSColor whiteColor];
			NSColor *black_color = [NSColor blackColor];
			
			self.highlightColorsArray = [NSArray arrayWithObjects:
										 [highlightColor blendedColorWithFraction:0.4 ofColor:white_color],
										 [highlightColor blendedColorWithFraction:0.2 ofColor:white_color],
										 [highlightColor blendedColorWithFraction:0.1 ofColor:black_color],
										 [highlightColor blendedColorWithFraction:0.05 ofColor:white_color],
										 [highlightColor blendedColorWithFraction:0.05 ofColor:black_color],
										 nil];
		}
	}
}

- (NSColor *) activeColor
{
	return activeColor;
}
- (void) setActiveColor:(NSColor *)newColor
{
	if (newColor != activeColor) {
		[activeColor release];
		activeColor = [newColor retain];
		
		// get color components to compose gradient colors
		if (nil != activeColor) {
			NSColor *white_color = [NSColor whiteColor];
			NSColor *black_color = [NSColor blackColor];
			
			self.activeColorsArray = [NSArray arrayWithObjects:
										 [activeColor blendedColorWithFraction:0.4 ofColor:white_color],
										 [activeColor blendedColorWithFraction:0.2 ofColor:white_color],
										 [activeColor blendedColorWithFraction:0.1 ofColor:black_color],
										 [activeColor blendedColorWithFraction:0.05 ofColor:white_color],
										 [activeColor blendedColorWithFraction:0.05 ofColor:black_color],
									  nil];
		}
	}
}

- (NSColor *) disabledColor
{
	return disabledColor;
}
- (void) setDisabledColor:(NSColor *)newColor
{
	if (newColor != disabledColor) {
		[disabledColor release];
		disabledColor = [newColor retain];
		
		// get color components to compose gradient colors
		if (nil != disabledColor) {
			NSColor *white_color = [NSColor whiteColor];
			NSColor *black_color = [NSColor blackColor];
			
			self.disabledColorsArray = [NSArray arrayWithObjects:
										 [disabledColor blendedColorWithFraction:0.4 ofColor:white_color],
										 [disabledColor blendedColorWithFraction:0.2 ofColor:white_color],
										 [disabledColor blendedColorWithFraction:0.1 ofColor:black_color],
										 [disabledColor blendedColorWithFraction:0.05 ofColor:white_color],
										 [disabledColor blendedColorWithFraction:0.05 ofColor:black_color],
										nil];
		}
	}
}
#pragma mark -



#pragma mark Drawing
- (void) drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	BOOL enabled = [self isEnabled];
	BOOL high = [self isHighlighted];
	BOOL active = (NSOnState == [self state]);
	
	// Get desired colors
	NSArray *color_array;
	if (!enabled) {
		color_array = disabledColorsArray;
	}
	else if (high) {
		color_array = highlightColorsArray;
	}
	else if (active) {
		color_array = activeColorsArray;
	}
	else {
		color_array = baseColorsArray;
	}
	const CGFloat locations[5] = { 0.0, 0.499, 0.5, 0.825, 1.0 };
	
	// Create the gradient and fill the background
	NSGradient *gradient = [[NSGradient alloc] initWithColors:color_array atLocations:locations colorSpace:[(NSColor *)[color_array objectAtIndex:0] colorSpace]];
	
	[gradient drawInRect:cellFrame angle:90.0];
	
	// Draw inner stuff
	if ([self isBordered]) {
		[self drawBezelWithFrame:cellFrame inView:controlView];
	}
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}


- (void) drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
	BOOL enabled = [self isEnabled];
	BOOL high = [self isHighlighted];
	BOOL active = ((NSOnOffButton | NSPushOnPushOffButton | NSToggleButton == button.buttonType) && NSOnState == [self state]);
	
	// Get desired color
	NSColor *border_color = enabled ? (high ? borderHighlightColor : (active ? borderActiveColor : borderColor)) : borderDisabledColor;
	[border_color setFill];
	
	// Create the border color
	NSNumber *top_border = [borderWidths objectAtIndex:2];
	NSNumber *right_border = [borderWidths objectAtIndex:3];
	NSNumber *bottom_border = [borderWidths objectAtIndex:0];
	NSNumber *left_border = [borderWidths objectAtIndex:1];
	
	CGFloat top_border_width = top_border && ((id)top_border != [NSNull null]) ? [top_border floatValue] : 0.0;
	CGFloat right_border_width = right_border && ((id)right_border != [NSNull null]) ? [right_border floatValue] : 0.0;
	CGFloat bottom_border_width = bottom_border && ((id)bottom_border != [NSNull null]) ? [bottom_border floatValue] : 0.0;
	CGFloat left_border_width = left_border && ((id)left_border != [NSNull null]) ? [left_border floatValue] : 0.0;
	
	// Draw the borders	
	NSRect top_border_rect = NSMakeRect(0.0, frame.size.height - top_border_width, frame.size.width, top_border_width);
	NSRectFill(top_border_rect);
	
	NSRect right_border_rect = NSMakeRect(frame.size.width - right_border_width, 0.0, right_border_width, frame.size.height);
	NSRectFill(right_border_rect);
	
	NSRect bottom_border_rect = NSMakeRect(0.0, 0.0, frame.size.width, bottom_border_width);
	NSRectFill(bottom_border_rect);
	
	NSRect left_border_rect = NSMakeRect(0.0, 0.0, left_border_width, frame.size.height);
	NSRectFill(left_border_rect);
}

- (void) drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSAttributedString *title = [self attributedTitle];
	NSSize title_size = [title size];
	
	NSRect draw_rect = cellFrame;
	draw_rect.size.height = title_size.height;
	draw_rect.origin.y = (cellFrame.size.height - title_size.height) / 2;
	
	[title drawInRect:draw_rect];
}


@end