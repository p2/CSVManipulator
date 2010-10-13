//
//  PPStringFormatEntity.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 30.08.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import <Cocoa/Cocoa.h>


@interface PPStringFormatEntity : NSObject <NSCopying, NSCoding> {
	NSString *separator;				// will be put between each key/value pair
	NSString *stringFormat;				// e.g. <$key>$value</$key>
	NSString *numberFormat;
	NSArray *keyTransforms;				// array full of PPStringFormatTransformPair-s
	NSArray *valueTransforms;			// dito
}

@property (nonatomic, copy) NSString *separator;
@property (nonatomic, copy) NSString *stringFormat;
@property (nonatomic, copy) NSString *numberFormat;
@property (nonatomic, retain) NSArray *keyTransforms;
@property (nonatomic, retain) NSArray *valueTransforms;

+ (PPStringFormatEntity *) formatEntity;

- (NSString *) stringForKeys:(NSArray *)keys values:(NSArray *)values;


@end
