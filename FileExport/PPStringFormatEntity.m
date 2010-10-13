//
//  PPStringFormatEntity.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 30.08.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import "PPStringFormatEntity.h"
#import "PPStringFormatTransformPair.h"


@implementation PPStringFormatEntity

@synthesize separator;
@synthesize stringFormat;
@synthesize numberFormat;
@synthesize keyTransforms;
@synthesize valueTransforms;


+ (PPStringFormatEntity *) formatEntity
{
	return [[[PPStringFormatEntity alloc] init] autorelease];
}

- (id) copyWithZone:(NSZone *)zone
{
	PPStringFormatEntity *copy = [[[self class] allocWithZone:zone] init];
	copy.separator = self.separator;
	copy.stringFormat = self.stringFormat;
	copy.numberFormat = self.numberFormat;
	
	copy->keyTransforms = [self.keyTransforms copyWithZone:zone];
	copy->valueTransforms = [self.valueTransforms copyWithZone:zone];
	
	return copy;
}

- (void) dealloc
{
	self.separator = nil;
	self.stringFormat = nil;
	self.numberFormat = nil;
	self.keyTransforms = nil;
	self.valueTransforms = nil;
	
	[super dealloc];
}
#pragma mark -



#pragma mark NSCoding
- (id) initWithCoder:(NSCoder *)aDecoder
{
	if (self = [self init]) {
		self.separator = [aDecoder decodeObjectForKey:@"separator"];
		self.stringFormat = [aDecoder decodeObjectForKey:@"stringFormat"];
		self.numberFormat = [aDecoder decodeObjectForKey:@"numberFormat"];
		
		self.keyTransforms = [aDecoder decodeObjectForKey:@"keyTransforms"];
		self.valueTransforms = [aDecoder decodeObjectForKey:@"valueTransforms"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:separator forKey:@"separator"];
	[aCoder encodeObject:stringFormat forKey:@"stringFormat"];
	[aCoder encodeObject:numberFormat forKey:@"numberFormat"];
	[aCoder encodeObject:keyTransforms forKey:@"keyTransforms"];
	[aCoder encodeObject:valueTransforms forKey:@"valueTransforms"];
}
#pragma mark -



#pragma mark Formatting
- (NSString *) stringForKeys:(NSArray *)keys values:(NSArray *)values
{
	NSString *string = @"";
	if (nil != keys) {
		NSMutableArray *parts = [NSMutableArray array];
		
		// loop the entries
		NSUInteger i = 0;
		for (NSString *key in keys) {
			id value = [values objectAtIndex:i];
			NSMutableString *formatted = nil;
			
			// NSString
			if ([value isKindOfClass:[NSString class]] && (nil != stringFormat)) {
				formatted = [stringFormat mutableCopy];		// e.g. "<$key>$value</$key>"
				NSString *newKey = key;
				NSString *newValue = value;					// this will be 'value' with escaped strings
				
				// escape characters
				if ([keyTransforms count] > 0) {
					newKey = [NSMutableString stringWithString:key];
					
					for (PPStringFormatTransformPair *transformPair in keyTransforms) {
						[transformPair transform:(NSMutableString *)newKey];
					}
				}
				
				if ([valueTransforms count] > 0) {
					newValue = [NSMutableString stringWithString:value];
					
					for (PPStringFormatTransformPair *transformPair in valueTransforms) {
						[transformPair transform:(NSMutableString *)newValue];
					}
				}
				
				[formatted replaceOccurrencesOfString:@"$key" withString:newKey options:0 range:NSMakeRange(0, [formatted length])];
				[formatted replaceOccurrencesOfString:@"$value" withString:newValue options:0 range:NSMakeRange(0, [formatted length])];
			}
			
			// NS(Decimal)Number
			else if ([value isKindOfClass:[NSNumber class]]) {
				formatted = (nil != numberFormat) ? [numberFormat mutableCopy] : [stringFormat mutableCopy];		// e.g. '$value'
				NSString *newValue = [value stringValue];
				
				[formatted replaceOccurrencesOfString:@"$key" withString:key options:0 range:NSMakeRange(0, [formatted length])];
				[formatted replaceOccurrencesOfString:@"$value" withString:newValue options:0 range:NSMakeRange(0, [formatted length])];
			}
			
			// add to the parts (no check necessary, formatted points at least to an empty string)
			[parts addObject:((nil == formatted) ? @"" : [formatted autorelease])];
			i++;
		}
		
		string = [parts componentsJoinedByString:separator];
	}
	
	return string;
}


@end
