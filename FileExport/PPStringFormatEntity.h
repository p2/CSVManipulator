//
//  PPStringFormatEntity.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 30.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PPStringFormatEntity : NSObject <NSCopying> {
	NSString *separator;				// will be put between each key/value pair
	NSString *stringFormat;				// e.g. <$key>$value</$key>
	NSString *numberFormat;
	NSArray *keyTransforms;				// array full of PPStringFormatTransformPair-s
	NSArray *valueTransforms;			// dito
}

@property (copy) NSString *separator;
@property (copy) NSString *stringFormat;
@property (copy) NSString *numberFormat;
@property (retain) NSArray *keyTransforms;
@property (retain) NSArray *valueTransforms;

+ (PPStringFormatEntity *) formatEntity;

- (NSString *) stringForKeys:(NSArray *)keys values:(NSArray *)values;


@end
