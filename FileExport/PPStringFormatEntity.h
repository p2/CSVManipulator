//
//  PPStringFormatEntity.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 30.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PPStringFormatEntity : NSObject {
	NSString *separator;				// will be put between each key/value pair
	NSString *stringformat;				// e.g. <$key>$value</$key>
	NSString *numberformat;
	NSArray *stringEscapeFrom;			// v should be the same length
	NSArray *stringEscapeTo;			// ^ should be the same length
}

@property (copy) NSString *separator;
@property (copy) NSString *stringformat;
@property (copy) NSString *numberformat;
@property (retain) NSArray *stringEscapeFrom;
@property (retain) NSArray *stringEscapeTo;

+ (PPStringFormatEntity *) entity;

- (NSString *) stringForKeys:(NSArray *)keys values:(NSArray *)values;


@end
