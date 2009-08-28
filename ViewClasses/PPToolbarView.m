//
//  PPToolbarView.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 28.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PPToolbarView.h"


@implementation PPToolbarView

@synthesize borderWidths;
@synthesize borderColor;

@dynamic baseColor;
@synthesize baseColorsArray;


- (id) initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		NSNumber *default_border_width = [NSNumber numberWithInt:1.0];
		self.borderWidths = [NSArray arrayWithObjects:default_border_width, default_border_width, default_border_width, default_border_width, nil];
		self.borderColor = [NSColor grayColor];
		self.baseColor = [NSColor whiteColor];
	}
	return self;
}

- (void) dealloc
{
	self.borderWidths = nil;
	self.borderColor = nil;
	
	self.baseColor = nil;
	self.baseColorsArray = nil;
	
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
#pragma mark -



#pragma mark Drawing
- (void) drawRect:(NSRect)rect
{
	const NSRect* draw_rects;
	NSInteger num_draw_rects;
	[self getRectsBeingDrawn:&draw_rects count:&num_draw_rects];
	
	if (num_draw_rects > 0) {
		NSRect my_bounds = [self bounds];
		NSUInteger i;
		
		// Create the gradient
		NSArray *color_array = self.baseColorsArray;
		const CGFloat locations[5] = { 0.0, 0.5, 0.5, 0.825, 1.0 };
		
		NSGradient *gradient = [[NSGradient alloc] initWithColors:color_array atLocations:locations colorSpace:[baseColor colorSpace]];
		
		// Create the border color
		[borderColor setFill];
		NSNumber *top_border = [borderWidths objectAtIndex:0];
		NSNumber *right_border = [borderWidths objectAtIndex:1];
		NSNumber *bottom_border = [borderWidths objectAtIndex:2];
		NSNumber *left_border = [borderWidths objectAtIndex:3];
		
		CGFloat top_border_width = top_border && ((id)top_border != [NSNull null]) ? [top_border floatValue] : 0.0;
		CGFloat right_border_width = right_border && ((id)right_border != [NSNull null]) ? [right_border floatValue] : 0.0;
		CGFloat bottom_border_width = bottom_border && ((id)bottom_border != [NSNull null]) ? [bottom_border floatValue] : 0.0;
		CGFloat left_border_width = left_border && ((id)left_border != [NSNull null]) ? [left_border floatValue] : 0.0;
		
		// Loop the rects where we need to draw
		for (i = 0; i < num_draw_rects; i++) {
			NSRect my_rect = draw_rects[i];
			my_rect.origin.y = my_bounds.origin.y;
			my_rect.size.height = my_bounds.size.height;
			
			// fill it
			[gradient drawInRect:my_rect angle:-90.0];
			
			// draw the borders if necessary
			if ((top_border_width > 0.0) && ((my_rect.origin.y + my_rect.size.height) > (my_bounds.size.height - top_border_width))) {			// top border
				NSRect this_border_rect = NSMakeRect(0.0, my_bounds.size.height - top_border_width, my_bounds.size.width, top_border_width);
				NSRectFill(NSIntersectionRect(my_bounds, this_border_rect));
			}
			if ((right_border_width > 0.0) && ((my_rect.origin.x + my_rect.size.width) > (my_bounds.size.width - right_border_width))) {		// right border
				NSRect this_border_rect = NSMakeRect(my_bounds.size.width - right_border_width, 0.0, right_border_width, my_bounds.size.height);
				NSRectFill(NSIntersectionRect(my_bounds, this_border_rect));
			}
			if ((bottom_border_width > 0.0) && (my_rect.origin.y < bottom_border_width)) {														// bottom border
				NSRect this_border_rect = NSMakeRect(0.0, 0.0, my_bounds.size.width, bottom_border_width);
				NSRectFill(NSIntersectionRect(my_bounds, this_border_rect));
			}
			if ((left_border_width > 0.0) && (my_rect.origin.x < left_border_width)) {															// left border
				NSRect this_border_rect = NSMakeRect(0.0, 0.0, left_border_width, my_bounds.size.height);
				NSRectFill(NSIntersectionRect(my_bounds, this_border_rect));
			}
		}
	}
}

@end
