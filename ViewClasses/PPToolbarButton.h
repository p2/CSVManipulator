//
//  PPToolbarButton.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 28.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PPToolbarView.h"


@interface PPToolbarButton : NSButton {
	NSButtonType buttonType;
	
	PPBorderWidth borderWidth;
	
	NSColor *borderColor;
	NSColor *borderHighlightColor;
	NSColor *borderActiveColor;
	NSColor *borderDisabledColor;
	
	NSColor *baseColor;					// gradient will be calculated from these ones
	NSColor *highlightColor;
	NSColor *activeColor;
	NSColor *disabledColor;
}

@property (nonatomic, assign) NSButtonType buttonType;

@property (nonatomic, assign) PPBorderWidth borderWidth;

@property (nonatomic, assign) NSColor *borderColor;
@property (nonatomic, assign) NSColor *borderHighlightColor;
@property (nonatomic, assign) NSColor *borderActiveColor;
@property (nonatomic, assign) NSColor *borderDisabledColor;

@property (nonatomic, assign) NSColor *baseColor;
@property (nonatomic, assign) NSColor *highlightColor;
@property (nonatomic, assign) NSColor *activeColor;
@property (nonatomic, assign) NSColor *disabledColor;


- (void) setDefaults;


@end
