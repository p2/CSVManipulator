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


@interface CSVDocument ()

- (void) setColumnDict:(NSDictionary *)newColumnDict;
- (void) notifyDelegateOfParsedRow:(CSVRow *)newRow;

@end



@implementation CSVDocument

@synthesize delegate;
@synthesize separator;
@synthesize rows;
@synthesize numRows;
@synthesize columnDict;
#ifndef IPHONE
@synthesize rowController;
#endif
@synthesize parseSuccessful;
@synthesize autoDetectSeparator;
@synthesize headerRows;
@synthesize mustAbortImport;
@synthesize didAbortImport;
@synthesize reportEveryRowParsed;
@synthesize columns;
@dynamic numHeaderRows;


- (id) init
{
	self = [super init];
	if (nil != self) {
		self.separator = @",";
		[self addColumn:[CSVColumn columnWithKey:@"col_0"]];
		self.rows = [NSMutableArray array];
#ifndef IPHONE
		self.rowController = [[[CSVRowController alloc] initWithContent:rows] autorelease];
		rowController.document = self;
#endif
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
#ifndef IPHONE
	self.rowController = nil;
#endif
	self.headerRows = nil;
	
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

- (NSUInteger) numHeaderRows
{
	return numHeaderRows;
}
- (void) setNumHeaderRows:(NSUInteger)newNum
{
	// MOVE all current header rows to the body
	if ([headerRows count] > 0) {
		for (CSVRow *hr in headerRows) {
#ifdef IPHONE
			[rows insertObject:hr atIndex:0];
#else
			[rowController insertObject:hr atArrangedObjectIndex:0];
#endif
			hr.isHeaderRow = NO;
			[headerRows removeObject:hr];
		}
	}
	
	// COPY data from the first x rows to the header and remove the rows from the body
	if (newNum > 0) {
		NSUInteger i;
		for (i = 0; i < newNum; i++) {
			if ([rows count] > i) {
#ifdef IPHONE
				[self setHeaderRow:[rows objectAtIndex:i]];
				[rows removeObjectAtIndex:i];
#else
				[self setHeaderRow:[[rowController arrangedObjects] objectAtIndex:i]];
				[rowController removeObjectAtArrangedObjectIndex:i];
#endif
			}
		}
	}
	
	// update num rows
	[self setNumRowsWithInt:[rows count]];
	
	numHeaderRows = newNum;
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
		self.columns = nil;
		BOOL sendRowUpdateToDelegate = reportEveryRowParsed && [delegate respondsToSelector:@selector(csvDocument:didParseRow:)];
		BOOL sendStatusUpdateToDelegate = (nil != delegate) && [delegate respondsToSelector:@selector(csvDocument:didParseNumRows:)];
		
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
		BOOL skipWhitespace = (NSNotFound == [separator rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location);
		BOOL isNewColumn = NO;				// will be YES when a new column is created
		BOOL columnHasName = NO;			// we use a BOOL here to avoid calling [column hasName] all too often
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
			isNewColumn = NO;
			columnHasName = NO;
			
			CSVRow *newRow = [CSVRow rowForDocument:self];
			
			// Scan row up to the next interesting character
			while (!finishedRow) {
				NSString *tempString;
				
				// get the current column or create a new one, if needed
				if ([columns count] > colIndex) {
					column = [columns objectAtIndex:colIndex];
					columnHasName = [column hasName];
				}
				else {
					column = [CSVColumn columnWithKey:[NSString stringWithFormat:@"col_%i", colIndex]];
					column.active = YES;
					isNewColumn = YES;
					columnHasName = NO;
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
						NSString *newCellString = [[currentCellString copy] autorelease];
						if (isNewColumn) {
							if (nil != newCellString && ![@"" isEqualToString:newCellString]) {
								column.name = newCellString;
								columnHasName = YES;
								if (nil == [self columnWithKey:newCellString]) {
									column.key = newCellString;
								}
							}
							[self addColumn:column];
							isNewColumn = NO;
						}
						if (!columnHasName) {
							column.name = newCellString;
						}
						
						[newRow setValue:newCellString forColumn:column];
						
						// on to the next column/cell!
						[currentCellString setString:@""];
						if (skipWhitespace) {
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
						NSString *newCellString = [[currentCellString copy] autorelease];
						if (isNewColumn) {
							if (nil != newCellString && ![@"" isEqualToString:newCellString]) {
								column.name = newCellString;
								columnHasName = YES;
								if (nil == [self columnWithKey:newCellString]) {
									column.key = newCellString;
								}
							}
							[self addColumn:column];
							isNewColumn = NO;
						}
						if (!columnHasName) {
							column.name = newCellString;
						}
						
						[newRow setValue:newCellString forColumn:column];
						finishedRow = YES;
					}
				}
				
				
				// found the end of the document
				else if ([scanner isAtEnd]) {
					NSString *newCellString = [[currentCellString copy] autorelease];
					if (isNewColumn) {
						if (nil != newCellString && ![@"" isEqualToString:newCellString]) {
							column.name = newCellString;
							columnHasName = YES;
							if (nil == [self columnWithKey:newCellString]) {
								column.key = newCellString;
							}
						}
						[self addColumn:column];
						isNewColumn = NO;
					}
					if (!columnHasName) {
						column.name = newCellString;
					}
					
					[newRow setValue:newCellString forColumn:column];
					finishedRow = YES;
				}
			}
			
			
			// one row scanned - add to our header and body arrays and save the columns
			if (num_rows >= numHeaderRows) {
				[rows addObject:newRow];
				
				// report to delegate if desired
				if (sendRowUpdateToDelegate) {
					[self performSelectorOnMainThread:@selector(notifyDelegateOfParsedRow:) withObject:newRow waitUntilDone:NO];
				}
			}
			else {
				[self setHeaderRow:newRow];
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
					[delegate csvDocument:self didParseNumRows:num_rows];
				}
			}
		}
		
		[innerPool release];
		[currentCellString release];
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
	
	// we're done here - tell the delegate
	if ([delegate respondsToSelector:@selector(csvDocumentDidParseString:)]) {
		[delegate csvDocumentDidParseString:self];
	}
	
	return success;
}
#pragma mark -



#pragma mark Returning as String
#ifdef CSV_STRING_EXPORTING
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
//	NSArray *headerRows = nil;
//	if (headerFlag && (nil != headerRow)) {
//		headerRows = [NSArray arrayWithObject:headerRow];
//	}
	
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
#endif
#pragma mark -



#pragma mark Column Handling
- (void) addColumn:(CSVColumn *) newColumn
{
	if (newColumn) {
		NSUInteger capacity = [columns count] + 1;
		NSMutableArray *columnArray = [NSMutableArray arrayWithCapacity:capacity];
		NSMutableDictionary *columnHash = [NSMutableDictionary dictionaryWithCapacity:capacity];
		
		// add existing columns
		for (CSVColumn *column in columns) {
			[columnArray addObject:column];
			[columnHash setObject:column forKey:column.key];
		}
		
		// add the new column
		[columnArray addObject:newColumn];
		[columnHash setObject:newColumn forKey:newColumn.key];
		
		self.columns = columnArray;
		[self setColumnDict:columnHash];
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

- (void) setHeaderRow:(CSVRow *)newHeaderRow
{
	if (newHeaderRow ) {
		newHeaderRow.isHeaderRow = YES;
		[headerRows addObject:newHeaderRow];
		
		// update column names (if they don't yet have a name)
		for (CSVColumn *column in columns) {
			if (!column.name) {
				column.name = [newHeaderRow valueForColumn:column];
			}
		}
	}
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


- (CSVColumn *) columnWithKey:(NSString *)columnKey
{
	return [columnDict objectForKey:columnKey];
}

- (NSString *) nameForColumnKey:(NSString *)columnKey
{	
	return [self nameForColumnKey:columnKey quoted:NO];
}

- (NSString *) nameForColumnKey:(NSString *)columnKey quoted:(BOOL)quoted
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
- (void) notifyDelegateOfParsedRow:(CSVRow *)newRow				// used to perform the delegate action on a different thread
{
	[delegate csvDocument:self didParseRow:newRow];
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"%@ <0x%X>; %@ rows", NSStringFromClass([self class]), self, numRows];
}



@end
