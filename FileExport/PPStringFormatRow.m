//
//  PPStringFormatRow.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 30.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PPStringFormatRow.h"
#import "PPStringFormatEntity.h"


@implementation PPStringFormatRow

@synthesize format;
@synthesize newline;

@synthesize keyFormat;
@synthesize valueFormat;


+ (PPStringFormatRow *) formatRow
{
	return [[[PPStringFormatRow alloc] init] autorelease];
}

- (id) init
{
	self = [super init];
	if (self) {
		self.newline = YES;
	}
	return self;
}

- (id) copyWithZone:(NSZone *)zone
{
	PPStringFormatRow *copy = [[[self class] allocWithZone:zone] init];
	copy.format = self.format;
	copy.newline = self.newline;
	
	copy->keyFormat = [self.keyFormat copyWithZone:zone];
	copy->valueFormat = [self.valueFormat copyWithZone:zone];
	
	return copy;
}

- (void) dealloc
{
	self.format = nil;
	
	self.keyFormat = nil;
	self.valueFormat = nil;
	
	[super dealloc];
}
#pragma mark -



#pragma mark NSCoding
- (id) initWithCoder:(NSCoder *)aDecoder
{
	if (self = [self init]) {
		self.format = [aDecoder decodeObjectForKey:@"format"];
		newline = [aDecoder decodeBoolForKey:@"newline"];
		
		self.keyFormat = [aDecoder decodeObjectForKey:@"keyFormat"];
		self.valueFormat = [aDecoder decodeObjectForKey:@"valueFormat"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:format forKey:@"format"];
	[aCoder encodeBool:newline forKey:@"newline"];
	
	[aCoder encodeObject:keyFormat forKey:@"keyFormat"];
	[aCoder encodeObject:valueFormat forKey:@"valueFormat"];
}
#pragma mark -



#pragma mark Formatting
- (NSString *) rowForKeys:(NSArray *)keys values:(NSArray *)values
{
	NSMutableString *string = nil;
	if (nil != keys && [keys count] > 0 && nil != format) {
		string = [NSMutableString stringWithString:format];
		
		// set keys
		if (nil != keyFormat && NSNotFound != [string rangeOfString:@"@keys"].location) {
			NSString *keyString = [keyFormat stringForKeys:keys values:values];
			[string replaceOccurrencesOfString:@"@keys"
									withString:keyString
									   options:0
										 range:NSMakeRange(0, [string length])];
		}
		
		// set values
		if (nil != valueFormat && NSNotFound != [string rangeOfString:@"@values"].location) {
			NSString *valueString = [valueFormat stringForKeys:keys values:values];
			[string replaceOccurrencesOfString:@"@values"
									withString:valueString
									   options:0
										 range:NSMakeRange(0, [string length])];
		}
		
		// add a newline
		if (newline) {
			[string appendString:@"\n"];
		}
	}
	
	return string;
}


@end
