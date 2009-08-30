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
@synthesize stringformat;
@synthesize numberformat;
@synthesize stringEscapeFrom;
@synthesize stringEscapeTo;


+ (PPStringFormatEntity *) entity
{
	return [[[PPStringFormatEntity alloc] init] autorelease];
}

- (void) dealloc
{
	self.separator = nil;
	self.stringformat = nil;
	self.numberformat = nil;
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
			NSMutableString *formatted = @"";
			
			// NSString
			if ([value isKindOfClass:[NSString class]] && (nil != stringformat)) {
				formatted = [stringformat mutableCopy];		// e.g. "<$key>$value</$key>"
				NSString *newValue = value;
				
				// escape characters in value
				if ([stringEscapeFrom count] > 0) {
					newValue = [NSMutableString stringWithString:value];
					NSUInteger i = 0;
					for (NSString *replaceFrom in stringEscapeFrom) {
						NSString *replaceTo = [stringEscapeTo objectAtIndex:i];
						
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
			else if ([value isKindOfClass:[NSNumber class]] && (nil != numberformat)) {
				formatted = [numberformat mutableCopy];		// e.g. '$value'
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
