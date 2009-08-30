//
//  PPStringFormat.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 29.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PPStringFormat.h"
#import "PPStringFormatRow.h"
#import "PPStringFormatEntity.h"
#import "CSVRow.h"


@implementation PPStringFormat

@synthesize name;

@synthesize prefix;
@synthesize suffix;

@synthesize headerFormat;
@synthesize valueFormat;


- (id) initWithName:(NSString *)newName
{
	self = [super init];
	if (self) {
		self.name = newName;
	}
	return self;
}

- (void) dealloc
{
	self.name = nil;
	
	self.prefix = nil;
	self.suffix = nil;
	
	self.headerFormat = nil;
	self.valueFormat = nil;
	
	[super dealloc];
}
#pragma mark -



#pragma mark Formatting
- (NSString *) stringForRows:(NSArray *)csvRows headerRows:(NSArray *)headerRows withKeys:(NSArray *)keys;
{
	NSMutableString *string = nil;
	
	if (nil != csvRows || nil != headerRows) {
		string = (nil == prefix) ? [NSMutableString string] : [NSMutableString stringWithString:prefix];
		
		// add header rows if we have any
		if ([headerRows count] > 0) {
			for (CSVRow *row in headerRows) {
				[string appendString:[headerFormat rowForKeys:keys values:[row valuesForColumnKeys:keys]]];
			}
		}
		
		// add rows if there are any
		if ([csvRows count] > 0) {
			NSAutoreleasePool *myPool = [[NSAutoreleasePool alloc] init];
			
			NSUInteger i = 0;
			for (CSVRow *row in csvRows) {
				[string appendString:[valueFormat rowForKeys:keys values:[row valuesForColumnKeys:keys]]];
				
				i++;
				
				// let's clean the pool from time to time
				if (0 == i % 50) {
					[myPool release];
					myPool = [[NSAutoreleasePool alloc] init];
				}
			}
			[myPool release];
		}
		
		if (nil != suffix) {
			[string appendString:suffix];
		}
	}
	
	return string;
}

- (NSString *) headerForKeys:(NSArray *)keys values:(NSArray *)values;
{
	return [headerFormat rowForKeys:keys values:values];
}

- (NSString *) rowForKeys:(NSArray *)keys values:(NSArray *)values;
{
	return [valueFormat rowForKeys:keys values:values];
}
#pragma mark -



#pragma mark Predefined formats
+ (PPStringFormat *) csvFormat
{
	PPStringFormat *myself = [[PPStringFormat alloc] initWithName:@"CSV"];
	
	// Setup CSV properties
	NSArray *escapeFrom = [NSArray arrayWithObject:@"\""];
	NSArray *escapeTo = [NSArray arrayWithObject:@"\"\""];
	
	PPStringFormatEntity *valueEntity = [PPStringFormatEntity entity];
	valueEntity.separator = @",";
	valueEntity.stringformat = @"\"$value\"";
	valueEntity.numberformat = @"$value";
	valueEntity.stringEscapeFrom = escapeFrom;
	valueEntity.stringEscapeTo = escapeTo;
	
	PPStringFormatRow *header = [PPStringFormatRow row];
	header.format = @"@values";
	header.valueFormat = valueEntity;
	
	PPStringFormatRow *row = [PPStringFormatRow row];
	row.format = @"@values";
	row.valueFormat = valueEntity;
	
	myself.headerFormat = header;
	myself.valueFormat = row;
	
	return [myself autorelease];
}

+ (PPStringFormat *) tabFormat
{
	PPStringFormat *myself = [[PPStringFormat alloc] initWithName:@"Tab"];
	
	// Setup Tab separated properties
	NSArray *escapeFrom = [NSArray arrayWithObject:@"\""];
	NSArray *escapeTo = [NSArray arrayWithObject:@"\"\""];
	
	PPStringFormatEntity *valueEntity = [PPStringFormatEntity entity];
	valueEntity.separator = @",";
	valueEntity.stringformat = @"\"$value\"";
	valueEntity.numberformat = @"$value";
	valueEntity.stringEscapeFrom = escapeFrom;
	valueEntity.stringEscapeTo = escapeTo;
	
	PPStringFormatRow *header = [PPStringFormatRow row];
	header.format = @"@values";
	header.valueFormat = valueEntity;
	
	PPStringFormatRow *row = [PPStringFormatRow row];
	row.format = @"@values";
	row.valueFormat = valueEntity;
	
	myself.headerFormat = header;
	myself.valueFormat = row;
	
	return [myself autorelease];
}

+ (PPStringFormat *) flatXMLFormat
{
	PPStringFormat *myself = [[PPStringFormat alloc] initWithName:@"flatXML"];
	
	// Setup CSV properties
	NSArray *replaceFrom = [NSArray arrayWithObjects:@"&", @"<", @">", @"\"", nil];
	NSArray *replaceTo = [NSArray arrayWithObjects:@"&amp;", @"&lt;", @"&gt;", @"&quot;", nil];
	
	PPStringFormatEntity *valueEntity = [PPStringFormatEntity entity];
	valueEntity.separator = @"\n\t";
	valueEntity.stringformat = @"<$key>$value</$key>";
	valueEntity.numberformat = @"<$key>$value</$key>";
	valueEntity.stringEscapeFrom = replaceFrom;
	valueEntity.stringEscapeTo = replaceTo;
	
	PPStringFormatRow *header = [PPStringFormatRow row];
	header.format = @"<header>\n\t@keys\n</header>";
	header.keyFormat = valueEntity;
	
	PPStringFormatRow *row = [PPStringFormatRow row];
	row.format = @"<row>\n\t@values\n</row>";
	row.valueFormat = valueEntity;
	
	myself.prefix = @"<root>\n";
	myself.suffix = @"</root>";
	myself.headerFormat = header;
	myself.valueFormat = row;
	
	return [myself autorelease];
}



@end
