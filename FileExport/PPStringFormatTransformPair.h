//
//  PPStringFormatTransformPair.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 10/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PPStringFormatTransformPair : NSObject {
	NSString *from;
	NSString *to;
}

@property (nonatomic, retain) NSString *from;
@property (nonatomic, retain) NSString *to;

+ (NSArray *) transformPairsFromTo:(NSString *)first, ...;

+ (PPStringFormatTransformPair *) pairFrom:(NSString *)newFrom to:(NSString *)newTo;
- (id) initFrom:(NSString *)newFrom to:(NSString *)newTo;

- (NSMutableString *) transform:(NSMutableString *)string;


@end
