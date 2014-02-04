//
//  PPStringFormatRow.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 30.08.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import <Cocoa/Cocoa.h>
@class PPStringFormatEntity;


/**
 *  A string format row applies holds transformation entities for header and value rows and applies these sub-transformations to its format of one CSV row.
 */
@interface PPStringFormatRow : NSObject <NSCopying, NSCoding> {
	NSString *format;							// e.g. <row>\n\t@values\n</row>
	
	PPStringFormatEntity *keyFormat;			// the format to apply to @keys
	PPStringFormatEntity *valueFormat;			// the format to apply to @values
}

@property (nonatomic, copy) NSString *format;

@property (nonatomic, retain) PPStringFormatEntity *keyFormat;
@property (nonatomic, retain) PPStringFormatEntity *valueFormat;

+ (PPStringFormatRow *) formatRow;

- (NSString *) rowForKeys:(NSArray *)keys values:(NSArray *)values;

@end
