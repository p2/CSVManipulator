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
#import "PPStringFormat.h"


@interface CSVDocument (Private)

- (void) setColumnDict:(NSDictionary *)newColumnDict;

@end



@implementation CSVDocument

@synthesize delegate, separator, rows, numRows, columnDict, rowController, parseSuccessful, autoDetectSeparator, headerRow, mustAbortImport, didAbortImport;
@synthesize columns;
@dynamic firstRowIsHeaderRow;


- (id) init
{
	self = [super init];
	if (nil != self) {
		self.separator = @",";
		[self setNewColumns:[NSArray arrayWithObject:[CSVColumn columnWithKey:@"col_0"]]];
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
	self.delegate = nil;
	self.separator = nil;
	self.rows = nil;
	self.numRows = nil;
	self.columns = nil;
	[self setColumnDict:nil];
	self.rowController = nil;
	self.headerRow = nil;
	
	[super dealloc];
}
#pragma mark -



#pragma mark  KVC
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
			CSVRow *headerCopy = [headerRow copy];
			[rowController insertObject:headerCopy atArrangedObjectIndex:0];
			[headerCopy release];
		}
	}
	
	// update num rows
	[self setNumRowsWithInt:[rows count]];
	
	firstRowIsHeaderRow = isHeaderRow;
}

- (void) setNumRowsWithInt:(NSInteger)num_rows
{
	[self willChangeValueForKey:@"numRows"];
	self.numRows = [NSNumber numberWithInt:num_rows];
	[self didChangeValueForKey:@"numRows"];
}
#pragma mark -



#pragma mark Parsing
- (NSUInteger) numRowsToExpect:(NSString *)string
{
	return [[string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] count];
}

- (BOOL) parseCSVString:(NSString *)string error:(NSError **)error
{
	return [self parseCSVString:string maxRows:0 error:error];
}

- (BOOL) parseCSVString:(NSString *)string maxRows:(NSUInteger)maxRows error:(NSError **)error
{
	NSUInteger num_rows = 0;
	BOOL success = YES;
	
	// this thing is thread safe
	[string retain];
	NSAutoreleasePool *outerPool = [[NSAutoreleasePool alloc] init];
	
	// String is non-empty
	if ([string length] > 0) {
		[rows removeAllObjects];
		BOOL sendStatusUpdateToDelegate = (nil != delegate) && [delegate respondsToSelector:@selector(csvDocumentDidParseNumRows:)];
		
		// collect the columns
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
		NSMutableCharacterSet *newlineCharacterSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
		[newlineCharacterSet formIntersectionWithCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
		
		// Characters where the parser should stop
		NSMutableCharacterSet *importantCharactersSet = [NSMutableCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%@\"", separator]];
		[importantCharactersSet formUnionWithCharacterSet:newlineCharacterSet];
		
		
		// Create scanner and scan the string
		// ideas for the following block from Drew McCormack >> http://www.macresearch.org/cocoa-scientists-part-xxvi-parsing-csv-data
		BOOL insideQuotes = NO;				// needed to determine whether we're inside doublequotes
		BOOL finishedRow = NO;				// used for the inner while loop
		CSVColumn *columnToRename = nil;	// if not nil will set the key to this column after a cell is finished
		
		NSMutableString *currentCellString = [[NSMutableString alloc] init];
		NSUInteger colIndex = 0;
		CSVColumn *column;
		
		// our NSScanner
		NSScanner *scanner = [NSScanner scannerWithString:string];
		[scanner setCharactersToBeSkipped:nil];
		
		// an inner pool for the loop
		NSAutoreleasePool *innerPool = [[NSAutoreleasePool alloc] init];
		while (![scanner isAtEnd]) {
			if (self.mustAbortImport) {
				self.didAbortImport = YES;
				break;
			}
			
			// we'll end up here after every row
			insideQuotes = NO;
			finishedRow = NO;
			[currentCellString setString:@""];
			colIndex = 0;
			
			CSVRow *newRow = [CSVRow rowForDocument:self];
			
			// Scan row up to the next interesting character
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
					
					if (firstRowIsHeaderRow) {
						columnToRename = column;
					}
				}
				
				// Scan characters into our string
				if ([scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString] ) {
					[currentCellString appendString:tempString];
				}
				
				// ***
				
				// found a doublequote (")
				if ([scanner scanString:@"\"" intoString:NULL]) {
					if (insideQuotes && [scanner scanString:@"\"" intoString:NULL]) { // Replace double - doublequotes with a single doublequote
						[currentCellString appendString:@"\""]; 
					}
					else {					// Start or end of a quoted string.
						insideQuotes = !insideQuotes;
					}
				}
				
				// found the separator
				else if ([scanner scanString:separator intoString:NULL]) {
					if (insideQuotes) {		// Separator character inside double quotes
						[currentCellString appendString:separator];
					}
					else {					// This is a column separating separator
						[newRow setValue:[[currentCellString copy] autorelease] forColumn:column];
						if (![column hasName]) {
							column.name = [newRow valueForColumn:column];
						}
						if (nil != columnToRename) {
							columnToRename.key = [newRow valueForColumn:column];
							columnToRename = nil;
						}
						
						// on to the next column/cell!
						[currentCellString setString:@""];
						if (NSNotFound == [separator rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location) {
							[scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
						}
						colIndex++;
					}
				}
				
				// found a newline
				else if ([scanner scanCharactersFromSet:newlineCharacterSet intoString:&tempString]) {
					if (insideQuotes) {		// We're inside quotes - add line break to column text
						[currentCellString appendString:tempString];
					}
					else {					// End of row
						[newRow setValue:[[currentCellString copy] autorelease] forColumn:column];
						if (![column hasName]) {
							column.name = [newRow valueForColumn:column];
						}
						if (nil != columnToRename) {
							columnToRename.key = [newRow valueForColumn:column];
							columnToRename = nil;
						}
						
						finishedRow = YES;
					}
				}
				
				
				// found the end
				else if ([scanner isAtEnd]) {
					[newRow setValue:[[currentCellString copy] autorelease] forColumn:column];
					if (![column hasName]) {
						column.name = [newRow valueForColumn:column];
					}
					if (nil != columnToRename) {
						columnToRename.key = [newRow valueForColumn:column];
						columnToRename = nil;
					}
					
					finishedRow = YES;
				}
			}
			
			
			// one row scanned - add to the lines array
			if ([newColumns count] > 0) {
				if (!firstRowIsHeaderRow || (num_rows > 1)) {
					[rows addObject:newRow];
				}
			}
			
			num_rows++;
			if ((maxRows > 0) && (num_rows > maxRows)) {
				break;
			}
			
			// clean the pool and update status
			if (0 == (num_rows % 100)) {
				[innerPool release];
				innerPool = [[NSAutoreleasePool alloc] init];
				
				if (sendStatusUpdateToDelegate) {
					[delegate csvDocumentDidParseNumRows:num_rows];
				}
			}
		}
		
		[innerPool release];
		[currentCellString release];
		
		// finished scanning our string; make first row the headerRow
		[self setNewColumns:newColumns];
		if ([rows count] > 0) {
			[self changeHeaderRow:[rows objectAtIndex:0]];
		}
	}
	
	// empty string
	else {
		NSDictionary *errorDict = [NSDictionary dictionaryWithObject:@"Cannot parse a nil string" forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:errorDict];
		success = NO;
	}
	
	// clean the outer pool
	[outerPool release];
	[string release];
	
	[self setNumRowsWithInt:num_rows];
	self.parseSuccessful = success;
	
	// tell the delegate
	if (nil != delegate) {
		[delegate csvDocumentDidParseString:self];
	}
	
	return success;
}
#pragma mark -



#pragma mark Returning as String
- (NSString *) stringInFormat:(PPStringFormat *)format withColumns:(NSArray *)columnArray forRowIndexes:(NSIndexSet *)rowIndexes writeHeader:(BOOL)headerFlag
{
	if ([columnArray count] < 1) {
		return @"";
	}
	
	if (nil == format) {
		format = [PPStringFormat csvFormat];
	}
	
	
	// extract keys from column objects
	NSMutableArray *columnKeys = [NSMutableArray arrayWithCapacity:[columnArray count]];
	for (CSVColumn *column in columnArray) {
		[columnKeys addObject:column.key];
	}
	
	// get header row
	NSArray *headerRows = nil;
	if(headerFlag && (nil != headerRow)) {
		headerRows = [NSArray arrayWithObject:headerRow];
	}
	
	// get desired row indexes if not given
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
	
	
	// get the string from the formatter
	return [format stringForRows:exportRows headerRows:headerRows withKeys:columnKeys];
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

- (void) setNewColumns:(NSArray *)newColumns
{
	if (columns != newColumns) {
		self.columns = newColumns;
		
		// we also represent the columns in a hash, mostly due to faster access and bindability
		if (nil != newColumns) {
			NSMutableDictionary *columnHash = [NSMutableDictionary dictionaryWithCapacity:[columns count]];
			for (CSVColumn *column in columns) {
				[columnHash setObject:column forKey:column.key];
			}
			[self setColumnDict:columnHash];
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

- (void) setColumnOrderByKeys:(NSArray *)newOrderKeys
{
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[newOrderKeys count]];
	for (NSString *columnKey in newOrderKeys) {
		CSVColumn *column = [columnDict objectForKey:columnKey];
		if (nil != column) {
			[arr addObject:column];
		}
	}
	
	self.columns = arr;
	NSLog(@"columns: %@", columns);
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
