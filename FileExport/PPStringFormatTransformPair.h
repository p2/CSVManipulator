//
//  PPStringFormatTransformPair.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 10/30/09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import <Cocoa/Cocoa.h>


/**
 *  A class that transforms occurrences of "from" to "to" in a mutable string.
 */
@interface PPStringFormatTransformPair : NSObject <NSCoding, NSCopying>

@property (nonatomic, retain) NSString *from;
@property (nonatomic, retain) NSString *to;

/** Create instances for all from-top pairs supplied as arugments. */
+ (NSArray *) transformPairsFromTo:(NSString *)first, ...;

/** Initialize and return a pair that transforms "fromStr" into "toStr". */
+ (PPStringFormatTransformPair *) pairFrom:(NSString *)fromStr to:(NSString *)toStr;

/** Designated initializer. */
- (id) initFrom:(NSString *)fromStr to:(NSString *)toStr;

/** Apply the transformation to the mutable string. */
- (NSMutableString *) transform:(NSMutableString *)string;

@end
