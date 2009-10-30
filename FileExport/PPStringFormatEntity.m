//
//  PPStringFormatEntity.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 30.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PPStringFormatEntity.h"


@implementation PPStringFormatEntity

@synthesize separator;
@synthesize stringFormat;
@synthesize numberFormat;
@synthesize stringEscapeFrom;
@synthesize stringEscapeTo;


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
	
	copy.stringEscapeFrom = [self.stringEscapeFrom copyWithZone:zone];
	copy.stringEscapeTo = [self.stringEscapeTo copyWithZone:zone];
	
	return copy;
}

- (void) dealloc
{
	self.separator = nil;
	self.stringFormat = nil;
	self.numberFormat = nil;
	self.stringEscapeFrom = nil;
	self.stringEscapeTo = nil;
	
	[super dealloc];
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
			NSMutableString *formatted = [NSMutableString string];
			
			// NSString
			if ([value isKindOfClass:[NSString class]] && (nil != stringFormat)) {
				formatted = [stringFormat mutableCopy];		// e.g. "<$key>$value</$key>"
				NSString *newValue = value;					// this will be 'value' with escaped strings
				
				// escape characters in value
				if ([stringEscapeFrom count] > 0) {
					newValue = [NSMutableString stringWithString:value];
					NSUInteger i = 0;
					NSUInteger num_to = [stringEscapeTo count];
					NSLog(@"escaping %@ %@", newValue, stringEscapeFrom);
					for (NSString *replaceFrom in stringEscapeFrom) {
						NSString *replaceTo = [stringEscapeTo objectAtIndex:(i % num_to)];
						
						[(NSMutableString *)newValue replaceOccurrencesOfString:replaceFrom
																	 withString:replaceTo
																		options:0
																		  range:NSMakeRange(0, [newValue length])];
						i++;
					}
				}
				
				[formatted replaceOccurrencesOfString:@"$key" withString:key options:0 range:NSMakeRange(0, [formatted length])];
				[formatted replaceOccurrencesOfString:@"$value" withString:newValue options:0 range:NSMakeRange(0, [formatted length])];
			}
			
			// NS(Decimal)Number
			else if ([value isKindOfClass:[NSNumber class]] && (nil != numberFormat)) {
				formatted = [numberFormat mutableCopy];		// e.g. '$value'
				NSString *newValue = [value stringValue];
				
				[formatted replaceOccurrencesOfString:@"$key" withString:key options:0 range:NSMakeRange(0, [formatted length])];
				[formatted replaceOccurrencesOfString:@"$value" withString:newValue options:0 range:NSMakeRange(0, [formatted length])];
			}
			
			// add to the parts (no check necessary, formatted points at least to an empty string)
			[parts addObject:formatted];
			i++;
		}
		
		string = [parts componentsJoinedByString:separator];
	}
	
	return string;
}


@end
