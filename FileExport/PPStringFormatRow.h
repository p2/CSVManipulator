//
//  PPStringFormatRow.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 30.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PPStringFormatEntity;


@interface PPStringFormatRow : NSObject {
	NSString *format;							// e.g. <row>\n\t@values\n</row>
	BOOL newline;								// if YES adds a newline after the row
	
	PPStringFormatEntity *keyFormat;			// the format to apply to @keys
	PPStringFormatEntity *valueFormat;			// the format to apply to @values
}

@property (copy) NSString *format;
@property (assign) BOOL newline;

@property (retain) PPStringFormatEntity *keyFormat;
@property (retain) PPStringFormatEntity *valueFormat;

+ (PPStringFormatRow *) row;

- (NSString *) rowForColumnKeys:(NSArray *)keys values:(NSArray *)values;


@end
