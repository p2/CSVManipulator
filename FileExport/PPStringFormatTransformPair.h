//
//  PPStringFormatTransformPair.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 10/30/09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//
//	A class that transforms occurrences of "from" to "to" in a mutable string
//

#import <Cocoa/Cocoa.h>


@interface PPStringFormatTransformPair : NSObject <NSCoding> {
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
