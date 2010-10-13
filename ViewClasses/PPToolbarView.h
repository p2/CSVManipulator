//
//  PPToolbarView.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 28.08.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import <Cocoa/Cocoa.h>


typedef struct {
	CGFloat top, right, bottom, left;
} PPBorderWidth;

PPBorderWidth PPBorderWidthMake(CGFloat top, CGFloat right, CGFloat bottom, CGFloat left);
BOOL PPBorderWidthEqualToBorderWidth(PPBorderWidth first, PPBorderWidth second);

@interface PPToolbarView : NSView {
	PPBorderWidth borderWidth;			// like in CSS: top right bottom left
	NSColor *borderColor;
	NSColor *baseColor;					// gradient will be calculated from this one
	
@private
	NSArray *baseColorsArray;
}

@property (nonatomic, assign) PPBorderWidth borderWidth;
@property (nonatomic, retain) NSColor *borderColor;
@property (nonatomic, retain) NSColor *baseColor;

@property (nonatomic, retain) NSArray *baseColorsArray;


@end
