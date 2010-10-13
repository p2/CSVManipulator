//
//  PPToolbarButton.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 28.08.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import <Cocoa/Cocoa.h>
#import "PPToolbarButton.h"


@interface PPToolbarButtonCell : NSButtonCell {
	PPToolbarButton *button;
	
	PPBorderWidth borderWidth;
	
	NSColor *borderColor;
	NSColor *borderHighlightColor;
	NSColor *borderActiveColor;
	NSColor *borderDisabledColor;
	
	NSColor *baseColor;					// gradient will be calculated from these ones
	NSColor *highlightColor;
	NSColor *activeColor;
	NSColor *disabledColor;
	
@private
	NSArray *baseColorsArray;
	NSArray *highlightColorsArray;
	NSArray *activeColorsArray;
	NSArray *disabledColorsArray;
}


@property (nonatomic, assign) PPToolbarButton *button;

@property (nonatomic, assign) PPBorderWidth borderWidth;

@property (nonatomic, retain) NSColor *borderColor;
@property (nonatomic, retain) NSColor *borderHighlightColor;
@property (nonatomic, retain) NSColor *borderActiveColor;
@property (nonatomic, retain) NSColor *borderDisabledColor;

@property (nonatomic, retain) NSColor *baseColor;
@property (nonatomic, retain) NSColor *highlightColor;
@property (nonatomic, retain) NSColor *activeColor;
@property (nonatomic, retain) NSColor *disabledColor;

@property (nonatomic, retain) NSArray *baseColorsArray;
@property (nonatomic, retain) NSArray *highlightColorsArray;
@property (nonatomic, retain) NSArray *activeColorsArray;
@property (nonatomic, retain) NSArray *disabledColorsArray;


@end
