//
//  CSVDocument.m
//  QuickLookCSV
//
//  Created by Pascal Pfiffner on 03.07.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//  

#import "CSVDocument.h"
#import "CSVRow.h"
#import "CSVColumn.h"
#import "CSVRowController.h"


@interface CSVDocument (Private)

- (void) setColumnDict:(NSDictionary *)newColumnDict;

@end



@implementation CSVDocument

@synthesize separator, rows, numRows, columnDict, rowController, autoDetectSeparator, headerRow;
@dynamic columns, firstRowIsHeaderRow;


- (id) init
{
	self = [super init];
	if (nil != self) {
		self.separator = @",";
		self.columns = [NSArray arrayWithObject:[CSVColumn columnWithKey:@"col_0"]];
		self.rows = [NSMutableArray array];
		self.rowController = [[[CSVRowController alloc] initWithContent:rows] autorelease];
		rowController.document = self;
	}
	
	return self;
}

+ (id) csvDocument
{
	return [[[self alloc] init] autorelease];
}

- (void) dealloc
{
	self.separator = nil;
	self.rows = nil;
	self.columns = nil;
	self.rowController = nil;
	self.headerRow = nil;
	
	[super dealloc];
}
#pragma mark -



#pragma mark  KVC
- (NSArray *) columns
{
	return columns;
}
- (void) setColumns:(NSArray *)newColumns
{
	if (newColumns != columns) {
		[columns release];
		columns = [newColumns retain];
		
		// we also represent the columns in a hash, mostly due to faster access and bindability
		if (nil != columns) {
			NSMutableDictionary *columnHash = [NSMutableDictionary dictionaryWithCapacity:[columns count]];
			for (CSVColumn *column in columns) {
				[columnHash setObject:column forKey:column.key];
			}
			[self setColumnDict:columnHash];
		}
	}
}

- (void) setColumnDict:(NSDictionary *)newColumnDict
{
	if (newColumnDict != columnDict) {
		[columnDict release];
		columnDict = [newColumnDict retain];
	}
}

- (BOOL) firstRowIsHeaderRow
{
	return firstRowIsHeaderRow;
}
- (void) setFirstRowIsHeaderRow:(BOOL)isHeaderRow
{
	// copy data from row 0 to the header and remove row 0
	if (isHeaderRow) {
		if ([rows count] > 0) {
			[self changeHeaderRow:[[rowController arrangedObjects] objectAtIndex:0]];
			[rowController removeObjectAtArrangedObjectIndex:0];
		}
	}
	
	// copy data from the header to a newly inserted row 0
	else {
		if (nil != headerRow) {
			[rowController insertObject:[headerRow copy] atArrangedObjectIndex:0];
		}
	}
	
	// update num rows
	[self willChangeValueForKey:@"numRows"];
	self.numRows = [NSNumber numberWithInt:[rows count]];
	[self didChangeValueForKey:@"numRows"];
	firstRowIsHeaderRow = isHeaderRow;
}
#pragma mark -



#pragma mark Parsing from String
- (BOOL) parseCSVString:(NSString *)string error:(NSError **)error
{
	return [self parseCSVString:string maxRows:0 error:error];
}

- (BOOL) parseCSVString:(NSString *)string maxRows:(NSUInteger)maxRows error:(NSError **)error
{
	NSUInteger num_rows = 0;
	
	// String is non-empty
	if ([string length] > 0) {
		[rows removeAllObjects];
		NSMutableArray *newColumns = [NSMutableArray array];
		
		// Check whether the file uses ";" or TAB as separator by comparing relative occurrences in the first 200 chars
		if (autoDetectSeparator) {
			self.separator = @",";
			
			NSUInteger testStringLength = ([string length] > 200) ? 200 : [string length];
			NSString *testString = [string substringToIndex:testStringLength];
			NSArray *possSeparators = [NSArray arrayWithObjects:@";", @"	", nil];
			
			for(NSString *s in possSeparators) {
				if ([[testString componentsSeparatedByString:s] count] > [[testString componentsSeparatedByString:separator] count]) {
					self.separator = s;
				}
			}
		}
		
		// Get newline character set
		NSMutableCharacterSet *newlineCharacterSet = (id)[NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
		[newlineCharacterSet formIntersectionWithCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
		
		// Characters where the parser should stop
		NSMutableCharacterSet *importantCharactersSet = (id)[NSMutableCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%@\"", separator]];
		[importantCharactersSet formUnionWithCharacterSet:newlineCharacterSet];
		
		
		// Create scanner and scan the string
		// ideas for the following block from Drew McCormack >> http://www.macresearch.org/cocoa-scientists-part-xxvi-parsing-csv-data
		BOOL insideQuotes = NO;				// needed to determine whether we're inside doublequotes
		BOOL finishedRow = NO;				// used for the inner while loop
		
		NSMutableString *currentCellString = [NSMutableString string];
		NSUInteger colIndex = 0;
		CSVColumn *column;
		
		NSScanner *scanner = [NSScanner scannerWithString:string];
		[scanner setCharactersToBeSkipped:nil];
		while (![scanner isAtEnd]) {
			
			// we'll end up here after every row
			insideQuotes = NO;
			finishedRow = NO;
			[currentCellString setString:@""];
			colIndex = 0;
			
			CSVRow *newRow = [CSVRow rowForDocument:self];
			
			// Scan row up to the next terminator
			while (!finishedRow) {
				NSString *tempString;
				
				// get the current column
				if ([newColumns count] > colIndex) {
					column = [newColumns objectAtIndex:colIndex];
				}
				else {
					column = [CSVColumn columnWithKey:[NSString stringWithFormat:@"col_%i", colIndex]];
					column.active = YES;
					[newColumns addObject:column];
				}
				
				
				// Scan characters into our string
				if ([scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString] ) {
					[currentCellString appendString:tempString];
				}
				
				
				// found the separator
				if ([scanner scanString:separator intoString:NULL]) {
					if (insideQuotes) {		// Separator character inside double quotes
						[currentCellString appendString:separator];
					}
					else {					// This is a column separating comma
						[newRow setValue:[currentCellString copy] forColumn:column];
						if (![column hasName]) {
							column.name = [newRow valueForColumn:column];
						}
						
						// on to the next column/cell!
						[currentCellString setString:@""];
						[scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
						colIndex++;
					}
				}
				
				
				// found a doublequote (")
				else if ([scanner scanString:@"\"" intoString:NULL]) {
					if (insideQuotes && [scanner scanString:@"\"" intoString:NULL]) { // Replace double - doublequotes with a single doublequote in our string.
						[currentCellString appendString:@"\""]; 
					}
					else {					// Start or end of a quoted string.
						insideQuotes = !insideQuotes;
					}
				}
				
				
				// found a newline
				else if ([scanner scanCharactersFromSet:newlineCharacterSet intoString:&tempString]) {
					if (insideQuotes) {		// We're inside quotes - add line break to column text
						[currentCellString appendString:tempString];
					}
					else {					// End of row
						[newRow setValue:[currentCellString copy] forColumn:column];
						if (![column hasName]) {
							column.name = [newRow valueForColumn:column];
						}
						finishedRow = YES;
					}
				}
				
				
				// found the end
				else if ([scanner isAtEnd]) {
					[newRow setValue:[currentCellString copy] forColumn:column];
					if (![column hasName]) {
						column.name = [newRow valueForColumn:column];
					}
					finishedRow = YES;
				}
			}
			
			
			// one row scanned - add to the lines array
			if ([newColumns count] > 0) {
				[rows addObject:newRow];
			}
			
			num_rows++;
			if ((maxRows > 0) && (num_rows > maxRows)) {
				break;
			}
		}
		
		// finished scanning our string; make first row the headerRow
		self.columns = newColumns;
		if ([rows count] > 0) {
			[self changeHeaderRow:[rows objectAtIndex:0]];
		}
	}
	
	// empty string
	else if (nil != error) {
		NSDictionary *errorDict = [NSDictionary dictionaryWithObject:@"Cannot parse an empty string" forKey:@"userInfo"];
		*error = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:errorDict];
		return NO;
	}
	
	self.numRows = [NSNumber numberWithInt:num_rows];
	return YES;
}
#pragma mark -



#pragma mark Returning as String
- (NSString *) stringInFormat:(NSUInteger)format withColumns:(NSArray *)columnArray forRowIndexes:(NSIndexSet *)rowIndexes writeHeader:(BOOL)headerFlag
{
	if ([columnArray count] < 1) {
		return @"";
	}
	
	// switch formats (CSV is default)
	NSString *fieldSeparator = @",";
	BOOL quoteStrings = YES;
	NSString *lineSeparator = @"\n";
	
	switch(format) {
		case 1:										// Tab
			fieldSeparator = @"\t";
			quoteStrings = NO;
			break;
			
		case 2:										// LaTeX
			fieldSeparator = @" & ";
			quoteStrings = NO;
			lineSeparator = @" \\\\\n";
			break;
		
		case 3:										// SQL
			break;
	}
	
	NSMutableString *csv = [NSMutableString string];
	
	// write headers
	if(headerFlag && (nil != headerRow)) {
		[csv appendString:[headerRow valuesForColumns:columnArray combinedByString:fieldSeparator quoted:quoteStrings]];
		[csv appendString:lineSeparator];
	}
	
	// get desired rows
	if (nil == rowIndexes) {
		if (NSNotFound == [rowController selectionIndex]) {
			NSRange fullRange = NSMakeRange(0, [rows count]);
			rowIndexes = [NSIndexSet indexSetWithIndexesInRange:fullRange];
		}
		else {
			rowIndexes = [rowController selectionIndexes];
		}
	}
	NSArray *exportRows = [[rowController arrangedObjects] objectsAtIndexes:rowIndexes];
	
	// write rows
	for (CSVRow *row in exportRows) {
		[csv appendString:[row valuesForColumns:columnArray combinedByString:fieldSeparator quoted:quoteStrings]];
		[csv appendString:lineSeparator];
	}
	
	return csv;
}
#pragma mark -



#pragma mark Column Handling
- (void) changeHeaderRow:(CSVRow *)newHeaderRow
{
	if (newHeaderRow != headerRow) {
		[self willChangeValueForKey:@"headerRow"];
		self.headerRow = newHeaderRow;
		[self didChangeValueForKey:@"headerRow"];
		
		// update column names
		if (nil != headerRow) {
			for (CSVColumn *column in columns) {
				column.name = [headerRow valueForColumn:column];
			}
		}
	}
}

- (BOOL) isFirstColumnKey:(NSString *)columnKey
{
	if ((nil != columns) && ([columns count] > 0)) {
		CSVColumn *firstColumn = [columns objectAtIndex:0];
		return [columnKey isEqualToString:firstColumn.name];
	}
	
	return NO;
}

- (BOOL) hasColumnKey:(NSString *)columnKey
{
	return (nil != [columnDict objectForKey:columnKey]);
}

- (NSString *) nameForColumn:(NSString *)columnKey
{	
	return [self nameForColumn:columnKey quoted:NO];
}

- (NSString *) nameForColumn:(NSString *)columnKey quoted:(BOOL)quoted
{
	NSString *name = ((CSVColumn *)[columnDict objectForKey:columnKey]).name;
	return quoted ? [NSString stringWithFormat:@"\"%@\"", name] : name;
}

- (void) setHeaderName:(NSString *)newName forColumnKey:(NSString *)columnKey
{
	CSVColumn *column = [columnDict objectForKey:columnKey];
	column.name = newName;
}

- (void) setHeaderActive:(BOOL)active forColumnKey:(NSString *)columnKey
{
	CSVColumn *column = [columnDict objectForKey:columnKey];
	column.active = active;
}
#pragma mark -



#pragma mark Row Handling
- (CSVRow *) rowAtIndex:(NSUInteger)rowIndex
{
	return [rows objectAtIndex:rowIndex];
}
#pragma mark -



#pragma mark Utilities
- (NSString *) description
{
	return [NSString stringWithFormat:@"%@ <0x%X>; %@ rows", [self className], self, numRows];
}



@end
