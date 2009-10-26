//
//  PPToolbarView.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 28.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
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
