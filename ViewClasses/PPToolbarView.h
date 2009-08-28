//
//  PPToolbarView.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 28.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PPToolbarView : NSView {
	NSArray *borderWidths;				// like in CSS: top right bottom left
	NSColor *borderColor;
	NSColor *baseColor;					// gradient will be calculated from this one
	
@private
	NSArray *baseColorsArray;
}

@property (nonatomic, retain) NSArray *borderWidths;
@property (nonatomic, retain) NSColor *borderColor;
@property (nonatomic, retain) NSColor *baseColor;

@property (nonatomic, retain) NSArray *baseColorsArray;


@end
