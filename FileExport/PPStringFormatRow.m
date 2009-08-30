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


+ (PPStringFormatRow *) row
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

- (void) dealloc
{
	self.format = nil;
	
	self.keyFormat = nil;
	self.valueFormat = nil;
	
	[super dealloc];
}
#pragma mark -



#pragma mark Formatting
- (NSString *) rowForKeys:(NSArray *)keys values:(NSArray *)values
{
	NSMutableString *string = nil;
	if ((nil != keys) && (nil != format)) {
		string = [NSMutableString stringWithString:format];
		
		// set keys
		if (NSNotFound != [string rangeOfString:@"@keys"].location) {
			[string replaceOccurrencesOfString:@"@keys"
									withString:[keyFormat stringForKeys:keys values:values]
									   options:0
										 range:NSMakeRange(0, [string length])];
		}
		
		// set values
		if (NSNotFound != [string rangeOfString:@"@values"].location) {
			[string replaceOccurrencesOfString:@"@values"
									withString:[valueFormat stringForKeys:keys values:values]
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
