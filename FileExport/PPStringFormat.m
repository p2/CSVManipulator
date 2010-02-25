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
#import "PPStringFormatTransformPair.h"
#import "CSVColumn.h"
#import "CSVRow.h"


@implementation PPStringFormat

@synthesize systemFormat;
@synthesize name;
@synthesize type;
@synthesize formatDescription;

@synthesize prefix;
@synthesize suffix;

@synthesize exportHeaders;
@synthesize useHeaderNamesAsKey;
@synthesize headerFormat;
@synthesize valueFormat;
@synthesize fileURL;


- (void) dealloc
{
	self.name = nil;
	self.type = nil;
	self.formatDescription = nil;
	
	self.prefix = nil;
	self.suffix = nil;
	
	self.headerFormat = nil;
	self.valueFormat = nil;
	
	self.fileURL = nil;
	
	[super dealloc];
}

- (id) initWithName:(NSString *)newName
{
	self = [super init];
	if (self) {
		self.name = newName;
		self.useHeaderNamesAsKey = YES;
		self.exportHeaders = YES;
	}
	return self;
}

- (id) copyWithZone:(NSZone *)zone
{
	PPStringFormat *copy = [[[self class] allocWithZone:zone] initWithName:self.name];
	// copies are never system formats, so don't assign the bool
	copy.type = self.type;
	copy.formatDescription = self.formatDescription;
	copy.prefix = self.prefix;
	copy.suffix = self.suffix;
	
	copy.exportHeaders = self.exportHeaders;
	copy.useHeaderNamesAsKey = self.useHeaderNamesAsKey;
	copy->headerFormat = [self.headerFormat copyWithZone:zone];
	copy->valueFormat = [self.valueFormat copyWithZone:zone];
	
	return copy;
}
#pragma mark -



#pragma mark NSCoding
- (id) initWithCoder:(NSCoder *)aDecoder
{
	if (self = [self init]) {
		self.name = [aDecoder decodeObjectForKey:@"name"];
		self.type = [aDecoder decodeObjectForKey:@"type"];
		self.formatDescription = [aDecoder decodeObjectForKey:@"formatDescription"];
		
		self.prefix = [aDecoder decodeObjectForKey:@"prefix"];
		self.suffix = [aDecoder decodeObjectForKey:@"suffix"];
		exportHeaders = [aDecoder decodeBoolForKey:@"exportHeaders"];
		useHeaderNamesAsKey = [aDecoder decodeBoolForKey:@"useHeaderNamesAsKey"];
		
		self.headerFormat = [aDecoder decodeObjectForKey:@"headerFormat"];
		self.valueFormat = [aDecoder decodeObjectForKey:@"valueFormat"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:name forKey:@"name"];
	[aCoder encodeObject:type forKey:@"type"];
	[aCoder encodeObject:formatDescription forKey:@"formatDescription"];
	[aCoder encodeObject:prefix forKey:@"prefix"];
	[aCoder encodeObject:suffix forKey:@"suffix"];
	[aCoder encodeBool:exportHeaders forKey:@"exportHeaders"];
	[aCoder encodeBool:useHeaderNamesAsKey forKey:@"useHeaderNamesAsKey"];
	
	[aCoder encodeObject:headerFormat forKey:@"headerFormat"];
	[aCoder encodeObject:valueFormat forKey:@"valueFormat"];
}
#pragma mark -



#pragma mark Formatting
- (NSString *) stringForRows:(NSArray *)csvRows andColumns:(NSArray *)columns;
{
	NSMutableString *string = nil;
	
	if (nil != csvRows) {
		
		// prepend the prefix
		string = (nil == prefix) ? [NSMutableString string] : [NSMutableString stringWithString:prefix];
		
		// add rows (if there are any)
		if ([csvRows count] > 0) {
			NSMutableArray *keys = [NSMutableArray arrayWithCapacity:[columns count]];
			NSAutoreleasePool *myPool = [[NSAutoreleasePool alloc] init];
			
			// extract the keys (actually: names) from the columns
			for (CSVColumn *column in columns) {
				NSString *newKey = (useHeaderNamesAsKey && [column hasName]) ? column.name : column.key;
				[keys addObject:newKey];
			}
			
			// loop the rows
			NSUInteger i = 0;
			for (CSVRow *row in csvRows) {
				if (!row.isHeaderRow) {
					[string appendString:[valueFormat rowForKeys:keys values:[row valuesForColumns:columns]]];		// value row
					i++;
				}
				else if (exportHeaders) {
					[string appendString:[headerFormat rowForKeys:keys values:[row valuesForColumns:columns]]];		// header row
					i++;
				}
				
				// let's clean the pool from time to time
				if (0 == i % 50) {
					[myPool release];
					myPool = [[NSAutoreleasePool alloc] init];
				}
			}
			[myPool release];
		}
		
		// append the suffix
		if (nil != suffix) {
			[string appendString:suffix];
		}
	}
	
	return string;
}

- (NSString *) headerForColumnKeys:(NSArray *)keys values:(NSArray *)values;
{
	return [headerFormat rowForKeys:keys values:values];
}

- (NSString *) rowForColumnKeys:(NSArray *)keys values:(NSArray *)values;
{
	return [valueFormat rowForKeys:keys values:values];
}
#pragma mark -



#pragma mark Loading and Saving from/to file
+ (PPStringFormat *) formatFromFile:(NSURL *)aFileURL error:(NSError **)outError
{
	NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
	
	// does the file exist and is readable?
	if (![fm isReadableFileAtPath:[aFileURL path]]) {
		NSString *err = [NSString stringWithFormat:@"File at %@ is not readable", [aFileURL path]];
		if (outError) {
			NSDictionary *errorDict = [NSDictionary dictionaryWithObject:err forKey:NSLocalizedDescriptionKey];
			*outError = [NSError errorWithDomain:NSCocoaErrorDomain code:11 userInfo:errorDict];
		}
		else {
			NSLog(@"%@", err);
		}
		return NO;
	}
	
	// unarchive
	PPStringFormat *stringFormat = [NSKeyedUnarchiver unarchiveObjectWithFile:[aFileURL path]];
	stringFormat.fileURL = aFileURL;
	
	return stringFormat;
}


- (BOOL) writeToFile:(NSURL *)aFileURL error:(NSError **)outError
{
	NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
	
	// can we write to the file if it already exists?
	if ([fm fileExistsAtPath:[aFileURL path]] && ![fm isWritableFileAtPath:[aFileURL path]]) {
		if (!outError) {
			NSLog(@"File at %@ is not writable", [aFileURL path]);
		}
		return NO;
	}
	
	return [NSKeyedArchiver archiveRootObject:self toFile:[aFileURL path]];
}

- (BOOL) save:(NSError **)outError
{
	if (nil == self.fileURL) {
		if (!outError) {
			NSLog(@"Can't save %@ without known URL", self.name);
		}
		return NO;
	}
	
	return [self writeToFile:fileURL error:outError];
}

- (BOOL) deleteFile:(NSError **)outError
{
	NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
	
	// if the file is still there (which it should), delete it!
	if ([fm fileExistsAtPath:[fileURL path]]) {
		if (![fm removeItemAtPath:[fileURL path] error:outError]) {
			if (!outError) {
				NSLog(@"File at %@ is not writable", [fileURL path]);
			}
			return NO;
		}
	}
	
	return YES;
}
#pragma mark -



#pragma mark Predefined formats
+ (PPStringFormat *) csvFormat
{
	PPStringFormat *myself = [[PPStringFormat alloc] initWithName:@"CSV"];
	myself.systemFormat = YES;
	myself.name = @"CSV";
	myself.type = @"csv";
	myself.formatDescription = @"Regular CSV format";
	
	// Setup CSV properties
	NSArray *transformPairs = [PPStringFormatTransformPair transformPairsFromTo:@"\"", @"\"\"", nil];
	
	PPStringFormatEntity *entity = [PPStringFormatEntity formatEntity];
	entity.separator = @",";
	entity.stringFormat = @"\"$value\"";
	entity.numberFormat = @"$value";
	entity.keyTransforms = transformPairs;
	entity.valueTransforms = transformPairs;
	
	PPStringFormatRow *header = [PPStringFormatRow formatRow];
	header.format = @"@values";
	header.valueFormat = entity;
	
	PPStringFormatRow *row = [PPStringFormatRow formatRow];
	row.format = @"@values";
	row.valueFormat = entity;
	
	myself.headerFormat = header;
	myself.valueFormat = row;
	
	return [myself autorelease];
}

+ (PPStringFormat *) tabFormat
{
	PPStringFormat *myself = [[PPStringFormat alloc] initWithName:@"Tab"];
	myself.systemFormat = YES;
	myself.name = @"Tab";
	myself.type = @"txt";
	myself.formatDescription = @"Regular tab separated values format";
	
	// Setup Tab separated properties
	NSArray *transformPairs = [PPStringFormatTransformPair transformPairsFromTo:@"\"", @"\"\"", nil];
	
	PPStringFormatEntity *entity = [PPStringFormatEntity formatEntity];
	entity.separator = @"\t";
	entity.stringFormat = @"\"$value\"";
	entity.numberFormat = @"$value";
	entity.keyTransforms = transformPairs;
	entity.valueTransforms = transformPairs;
	
	PPStringFormatRow *row = [PPStringFormatRow formatRow];
	row.format = @"@values";
	row.valueFormat = entity;
	
	myself.headerFormat = row;
	myself.valueFormat = row;
	
	return [myself autorelease];
}

+ (PPStringFormat *) flatXMLFormat
{
	PPStringFormat *myself = [[PPStringFormat alloc] initWithName:@"flatXML"];
	myself.systemFormat = YES;
	myself.name = @"XML";
	myself.type = @"xml";
	myself.formatDescription = @"A format that exports your file to a flat XML structure";
	myself.exportHeaders = NO;
	
	// Setup CSV properties
	NSArray *keyPairs = [PPStringFormatTransformPair transformPairsFromTo:
						 @"&", @"_",
						 @"<", @"_",
						 @">", @"_",
						 @"\"", @"_",
						 @" ", @"_",
						 @"\t", @"_",
						 @"\n", @"_", nil];
	NSArray *valuePairs = [PPStringFormatTransformPair transformPairsFromTo:
						   @"&", @"&amp;",
						   @"<", @"&lt;",
						   @">", @"&gt;",
						   @"\"", @"&quot;", nil];
	
	PPStringFormatEntity *valueEntity = [PPStringFormatEntity formatEntity];
	valueEntity.separator = @"\n\t";
	valueEntity.stringFormat = @"<$key>$value</$key>";
	valueEntity.numberFormat = @"<$key>$value</$key>";
	valueEntity.keyTransforms = keyPairs;
	valueEntity.valueTransforms = valuePairs;
	
	PPStringFormatEntity *headerEntity = [PPStringFormatEntity formatEntity];
	headerEntity.separator = @"\n\t";
	headerEntity.stringFormat = @"<$key name=\"$value\" />";
	headerEntity.numberFormat = @"<$key name=\"$value\" />";
	headerEntity.keyTransforms = keyPairs;
	headerEntity.valueTransforms = valuePairs;
	
	PPStringFormatRow *header = [PPStringFormatRow formatRow];
	header.format = @"<header>\n\t@keys\n</header>";
	header.keyFormat = headerEntity;
	
	PPStringFormatRow *row = [PPStringFormatRow formatRow];
	row.format = @"<row>\n\t@values\n</row>";
	row.valueFormat = valueEntity;
	
	myself.prefix = @"<root>\n";
	myself.suffix = @"</root>";
	myself.headerFormat = header;
	myself.valueFormat = row;
	
	return [myself autorelease];
}

+ (PPStringFormat *) sqlFormat
{
	PPStringFormat *myself = [[PPStringFormat alloc] initWithName:@"SQL"];
	myself.systemFormat = YES;
	myself.name = @"SQL";
	myself.type = @"sql";
	myself.formatDescription = @"A format that exports your file as basic SQL CREATE TABLE and INSERT statements";
	
	// Setup CSV properties
	NSArray *keyPairs = [PPStringFormatTransformPair transformPairsFromTo:		// TODO: Invent a pair that replaces all non-alphanumeric characters
						 @"&", @"_",
						 @"<", @"_",
						 @">", @"_",
						 @"\"", @"_",
						 @" ", @"_",
						 @"\t", @"_",
						 @"\n", @"_", nil];
	NSArray *valuePairs = [PPStringFormatTransformPair transformPairsFromTo:@"\"", @"&quot;", nil];
	
	PPStringFormatEntity *headerEntity = [PPStringFormatEntity formatEntity];
	headerEntity.separator = @",\n\t";
	headerEntity.stringFormat = @"`$key` VARCHAR(32)";
	headerEntity.keyTransforms = keyPairs;
	
	PPStringFormatEntity *keyEntity = [PPStringFormatEntity formatEntity];
	keyEntity.separator = @", ";
	keyEntity.stringFormat = @"`$key`";
	keyEntity.keyTransforms = keyPairs;
	
	PPStringFormatEntity *valueEntity = [PPStringFormatEntity formatEntity];
	valueEntity.separator = @", ";
	valueEntity.stringFormat = @"\"$value\"";
	valueEntity.numberFormat = @"$value";
	valueEntity.valueTransforms = valuePairs;
	
	PPStringFormatRow *header = [PPStringFormatRow formatRow];
	header.format = @"CREATE TABLE IF NOT EXISTS `my_table_name` (\n\t@keys\n) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT=\"my_table_comment\";";
	header.keyFormat = headerEntity;
	
	PPStringFormatRow *row = [PPStringFormatRow formatRow];
	row.format = @"INSERT INTO `my_table_name` (@keys) VALUES (@values);";
	row.keyFormat = keyEntity;
	row.valueFormat = valueEntity;
	
	myself.prefix = @"USE `my_database`;\n";
	myself.headerFormat = header;
	myself.valueFormat = row;
	
	return [myself autorelease];
}
#pragma mark -



#pragma mark Utilities
- (NSString *) description
{
	return [NSString stringWithFormat:@"%@ <0x%x> %@ (system: %i)", NSStringFromClass([self class]), self, name, systemFormat];
}



@end
