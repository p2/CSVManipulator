//
//  PPToolbarView.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 28.08.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import "PPToolbarView.h"


@implementation PPToolbarView

@synthesize borderWidth;
@synthesize borderColor;

@dynamic baseColor;
@synthesize baseColorsArray;


- (id) initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.borderWidth = PPBorderWidthMake(1.0, 1.0, 1.0, 1.0);
		self.borderColor = [NSColor grayColor];
		self.baseColor = [NSColor whiteColor];
	}
	return self;
}

- (void) dealloc
{
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
		
		// Create the gradient and set the border color
		NSArray *color_array = self.baseColorsArray;
		const CGFloat locations[5] = { 0.0, 0.5, 0.5, 0.825, 1.0 };
		NSGradient *gradient = [[NSGradient alloc] initWithColors:color_array atLocations:locations colorSpace:[baseColor colorSpace]];
		[borderColor setFill];
		
		// Loop the rects where we need to draw
		for (i = 0; i < num_draw_rects; i++) {
			NSRect my_rect = draw_rects[i];
			my_rect.origin.y = my_bounds.origin.y;
			my_rect.size.height = my_bounds.size.height;
			
			// fill it
			[gradient drawInRect:my_rect angle:-90.0];
			
			// draw the borders if necessary
			if ((borderWidth.top > 0.0) && ((my_rect.origin.y + my_rect.size.height) > (my_bounds.size.height - borderWidth.top))) {			// top border
				NSRect this_border_rect = NSMakeRect(0.0, my_bounds.size.height - borderWidth.top, my_bounds.size.width, borderWidth.top);
				NSRectFill(NSIntersectionRect(my_bounds, this_border_rect));
			}
			if ((borderWidth.right > 0.0) && ((my_rect.origin.x + my_rect.size.width) > (my_bounds.size.width - borderWidth.right))) {		// right border
				NSRect this_border_rect = NSMakeRect(my_bounds.size.width - borderWidth.right, 0.0, borderWidth.right, my_bounds.size.height);
				NSRectFill(NSIntersectionRect(my_bounds, this_border_rect));
			}
			if ((borderWidth.bottom > 0.0) && (my_rect.origin.y < borderWidth.bottom)) {														// bottom border
				NSRect this_border_rect = NSMakeRect(0.0, 0.0, my_bounds.size.width, borderWidth.bottom);
				NSRectFill(NSIntersectionRect(my_bounds, this_border_rect));
			}
			if ((borderWidth.left > 0.0) && (my_rect.origin.x < borderWidth.left)) {															// left border
				NSRect this_border_rect = NSMakeRect(0.0, 0.0, borderWidth.left, my_bounds.size.height);
				NSRectFill(NSIntersectionRect(my_bounds, this_border_rect));
			}
		}
		
		[gradient release];
	}
}
#pragma mark -



#pragma mark Helper Functions
PPBorderWidth PPBorderWidthMake(CGFloat top, CGFloat right, CGFloat bottom, CGFloat left)
{
	PPBorderWidth width;
	width.top = top;
	width.right = right;
	width.bottom = bottom;
	width.left = left;
	
	return width;
}

BOOL PPBorderWidthEqualToBorderWidth(PPBorderWidth first, PPBorderWidth second)
{
	if (first.top == second.top) {
		if (first.right == second.right) {
			if (first.bottom == second.bottom) {
				if (first.left == second.left) {
					return YES;
				}
			}
		}
	}
	return NO;
}


@end
