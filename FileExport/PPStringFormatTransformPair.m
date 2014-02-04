//
//  PPStringFormatTransformPair.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 10/30/09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import "PPStringFormatTransformPair.h"
#import <stdarg.h>


@implementation PPStringFormatTransformPair


+ (NSArray *) transformPairsFromTo:(NSString *)first, ...
{
	NSMutableArray *pairs = [[NSMutableArray alloc] init];
	NSString *thisArg, *fromArg = nil;
	va_list arg_list;
	va_start(arg_list, first);
	
	for (thisArg = first; thisArg != nil; thisArg = va_arg(arg_list, NSString*)) {
		if (nil == fromArg) {
			fromArg = thisArg;
		}
		else {
			PPStringFormatTransformPair *newPair = [PPStringFormatTransformPair pairFrom:fromArg to:thisArg];
			[pairs addObject:newPair];
			fromArg = nil;
		}
		// had problems with this...
//		thisArg = va_arg(arg_list, NSString*);
//		NSLog("...and fetched %@", thisArg);
	}
	va_end(arg_list);
	
	return [pairs autorelease];
}


+ (PPStringFormatTransformPair *) pairFrom:(NSString *)fromStr to:(NSString *)toStr
{
	PPStringFormatTransformPair *newPair = [[self alloc] initFrom:fromStr to:toStr];
	return [newPair autorelease];
}

- (id) initFrom:(NSString *)fromStr to:(NSString *)toStr
{
	self = [super init];
	if (self) {
		self.from = fromStr;
		self.to = toStr;
	}
	return self;
}

- (void) dealloc
{
	self.from = nil;
	self.to = nil;
	
	[super dealloc];
}



#pragma mark - NSCoding
- (id) initWithCoder:(NSCoder *)aDecoder
{
	if (self = [self init]) {
		self.from = [aDecoder decodeObjectForKey:@"from"];
		self.to = [aDecoder decodeObjectForKey:@"to"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:_from forKey:@"from"];
	[aCoder encodeObject:_to forKey:@"to"];
}



#pragma mark - NSCopying
- (id) copyWithZone:(NSZone *)zone
{
	PPStringFormatTransformPair *copy = [[self class] new];
	copy.from = _from;
	copy.to = _to;
	
	return copy;
}



#pragma mark - Transforming
- (NSMutableString *) transform:(NSMutableString *)string
{
	if (nil != string) {
		[string replaceOccurrencesOfString:_from withString:_to options:0 range:NSMakeRange(0, [string length])];
	}
	return string;
}



#pragma mark - Utilities
- (NSString *) description
{
	return [NSString stringWithFormat:@"%@ <%p> from '%@' to '%@'", NSStringFromClass([self class]), self, _from, _to];
}


@end
