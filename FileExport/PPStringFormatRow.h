//
//  PPStringFormatRow.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 30.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PPStringFormatEntity;


@interface PPStringFormatRow : NSObject <NSCopying> {
	NSString *format;							// e.g. <row>\n\t@values\n</row>
	BOOL newline;								// if YES adds a newline after the row
	
	PPStringFormatEntity *keyFormat;			// the format to apply to @keys
	PPStringFormatEntity *valueFormat;			// the format to apply to @values
}

@property (nonatomic, copy) NSString *format;
@property (nonatomic, assign) BOOL newline;

@property (nonatomic, retain) PPStringFormatEntity *keyFormat;
@property (nonatomic, retain) PPStringFormatEntity *valueFormat;

+ (PPStringFormatRow *) formatRow;

- (NSString *) rowForKeys:(NSArray *)keys values:(NSArray *)values;


@end
