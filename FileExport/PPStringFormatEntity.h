//
//  PPStringFormatEntity.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 30.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PPStringFormatEntity : NSObject {
	NSString *separator;
	NSString *stringformat;
	NSString *numberformat;
	NSArray *stringEscapeFrom;
	NSArray *stringEscapeTo;
}

@property (copy) NSString *separator;
@property (copy) NSString *stringformat;
@property (copy) NSString *numberformat;
@property (retain) NSArray *stringEscapeFrom;
@property (retain) NSArray *stringEscapeTo;

+ (PPStringFormatEntity *) entity;

- (NSString *) stringForKeys:(NSArray *)keys values:(NSArray *)values;


@end
