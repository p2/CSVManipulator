//
//  MyDocument.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 21.02.08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import "MyDocument.h"
#import "CSVWindowController.h"
#import "CSVDocument.h"
#import "CSVRow.h"
#import "CSVColumn.h"
#import "PPStringFormat.h"
#import "DataTableView.h"
#import "DataTableColumn.h"
#import "DataTableHeaderCell.h"
#import "RegexKitLite.h"
#import "BC.h"


#define EXPRESSION_MAX_LEN 1023
#define kColumnHeaderNameKey @"name"
#define kColumnHeaderTypeKey @"type"
#define kColumnHeaderActiveKey @"active"



@interface MyDocument (Private)
- (void) detachStringParsing:(NSString *)string;
@end



@implementation MyDocument

@synthesize fileEncoding;
@synthesize csvDocument;
@synthesize documentLoaded;
@dynamic documentEdited;
@dynamic dataIsAtOriginalOrder;
@synthesize exportHeaders;
@synthesize calculationShouldTerminate;
@dynamic documentFormat;


#pragma mark Generic
- (id) init
{
	self = [super init];
	if (nil != self) {
		exportHeaders = YES;
		documentLoaded = YES;				// will be set to know when we got instantiated by reading from URL
		dataIsAtOriginalOrder = YES;
		
		self.csvDocument = [CSVDocument csvDocument];
		csvDocument.delegate = self;
	}
	
    return self;
}

- (void) dealloc
{
	self.csvDocument = nil;
	self.documentFormat = nil;
 	
	[super dealloc];
}
#pragma mark -



#pragma mark KVC
- (BOOL) isDocumentEdited
{
	return documentEdited || !dataIsAtOriginalOrder;
}
- (void) setDocumentEdited:(BOOL)flag
{
	if (flag != documentEdited) {
		[self willChangeValueForKey:@"documentEdited"];
		documentEdited = flag;
		[self didChangeValueForKey:@"documentEdited"];
	}
}

- (BOOL) dataIsAtOriginalOrder
{
	return dataIsAtOriginalOrder;
}
- (void) setDataIsAtOriginalOrder:(BOOL)flag
{
	if (flag != dataIsAtOriginalOrder) {
		[self willChangeValueForKey:@"dataIsAtOriginalOrder"];
		[self willChangeValueForKey:@"documentEdited"];
		dataIsAtOriginalOrder = flag;
		[self didChangeValueForKey:@"dataIsAtOriginalOrder"];
		[self didChangeValueForKey:@"documentEdited"];
	}
}

- (PPStringFormat *) documentFormat
{
	if (nil == documentFormat) {
		self.documentFormat = [PPStringFormat csvFormat];
	}
	
	return documentFormat;
}
- (void) setDocumentFormat:(PPStringFormat *)newFormat
{
	if (newFormat != documentFormat) {
		[documentFormat release];
		documentFormat = [newFormat retain];
	}
}
#pragma mark -



#pragma mark Opening Files
// the open-a-file sequence
//	openDocument:										<< NSDocumentController >>
//	openDocumentWithContentsOfURL:display:error:		<< NSDocumentController >>
//	makeDocumentWithContentsOfURL:ofType:error:			<< NSDocumentController >>
//	initWithContentsOfURL:ofType:error:					<< NSDocument >>
//	readFromURL:ofType:error:							<< NSDocument >>
//	readFromFileWrapper:ofType:error:					<< NSDocument >>
//	readFromData:ofType:error:							<< NSDocument >>

- (BOOL) readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	self.documentLoaded = NO;
	[self setFileURL:absoluteURL];
	
	// TODO: create an NSFileWrapper > fileWrapperOfType:error:
	
	// Load document data using NSStrings house methods
	// For huge files, maybe guess file encoding using `file --brief --mime` and use NSFileHandle? Not for now...
	NSStringEncoding stringEncoding;
	NSString *fileString = [NSString stringWithContentsOfURL:absoluteURL usedEncoding:&stringEncoding error:outError];
	
	// We could not open the file, explicitly try utf-8
	if (nil == fileString) {
		stringEncoding = NSUTF8StringEncoding;
		fileString = [NSString stringWithContentsOfURL:absoluteURL encoding:stringEncoding error:outError];
		
		// We could still not open the file, probably unknown encoding; try ISO-8859-1
		if (nil == fileString) {
			stringEncoding = NSISOLatin1StringEncoding;
			fileString = [NSString stringWithContentsOfURL:absoluteURL encoding:stringEncoding error:outError];
			
			// Still no success, give up
			if (nil == fileString) {
				[self presentError:*outError];
				
				return NO;
			}
		}
	}
	
	// parse the CSV on another thread
	self.fileEncoding = stringEncoding;
	numRowsToExpect = [csvDocument numRowsToExpect:fileString];
	
	// detach to new thread
	[NSThread detachNewThreadSelector:@selector(detachStringParsing:) toTarget:self withObject:fileString];
	
	return YES;
}

- (void) detachStringParsing:(NSString *)string
{
	NSAutoreleasePool *detachPool = [[NSAutoreleasePool alloc] init];
	NSError *error;
	
	if ([csvDocument parseCSVString:string maxRows:0 error:&error]) {
		self.documentFormat = [PPStringFormat csvFormat];
	}
	else {
		[self presentError:error];
	}
	
	[detachPool release];
}
#pragma mark -



#pragma mark CSVDocument Delegate
- (void) csvDocument:(CSVDocument *)document didParseNumRows:(NSUInteger)num_parsed
{
	CGFloat expecting = (numRowsToExpect > 0) ? (CGFloat)numRowsToExpect : 1.0;
	CGFloat percentage = (CGFloat)num_parsed / expecting;
	percentage = (percentage > 1.0) ? 1.0 : percentage;
	
	[mainWindowController updateProgressSheetProgress:percentage];
}

- (void) csvDocumentDidParseString:(CSVDocument *)document
{
	self.documentLoaded = YES;
	
	[mainWindowController redefineTable];
	[mainWindowController hideProgressSheet];
	
	// did we abort?
	[mainWindowController didAbortImport:document.didAbortImport];
}

- (void) csvDocument:(CSVDocument *)document didChangeRowOrderToOriginalOrder:(BOOL)isOriginalOrder
{
	self.dataIsAtOriginalOrder = isOriginalOrder;
	if (isOriginalOrder) {
		[mainWindowController didRestoreOriginalOrder];
	}
}
#pragma mark -



#pragma mark Saving Files
// the save-a-file sequence
//	saveDocument:								<< NSDocument >>
//	writeToURL:ofType:error:					<< NSDocument >>
//	fileWrapperOfType:error:					<< NSDocument >>
//	writeToFile:atomically:updateFilenames:		<< NSFileWrapper >>

- (BOOL) writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	// TODO: Use CSV format for SAVE operations, selected format for EXPORT oporations
	NSString *csvString = [self stringInFormat:self.documentFormat allRows:YES allColumns:YES];
	
	// save file
	BOOL success = [csvString writeToURL:absoluteURL atomically:YES encoding:NSUTF8StringEncoding error:outError];
	self.documentEdited = !success;
	
	return success;
}

- (NSString *) stringInFormat:(PPStringFormat *)format allRows:(BOOL)allRows allColumns:(BOOL)allColumns;
{
	// get the row indexes we want
	NSIndexSet *rowIndexes = nil;
	if (allRows) {
		NSRange fullRange = NSMakeRange(0, [csvDocument.rows count]);
		rowIndexes = [NSIndexSet indexSetWithIndexesInRange:fullRange];
	}
	
	// get columns
	NSArray *columns;
	if (allColumns) {
		columns = csvDocument.columns;
	}
	else {
		NSMutableArray *foo = [NSMutableArray array];
		for (CSVColumn *column in csvDocument.columns) {
			if (column.active) {
				[foo addObject:column];
			}
		}
		columns = [foo copy];
	}
	
	// TODO: Export headers, other mechanism desired
	return [csvDocument stringInFormat:format withColumns:columns forRowIndexes:rowIndexes includeHeaders:exportHeaders];
}
#pragma mark -



#pragma mark Data Control
- (NSUInteger) numColumns
{
	return [csvDocument.columns count];
}

- (NSArray *) columns
{
	return csvDocument.columns;
}

- (void) addCSVRow:(id)sender
{
	[csvDocument.rowController add:sender];
	self.documentEdited = YES;
}
- (void) removeCSVRow:(id)sender
{
	[csvDocument.rowController remove:sender];
	self.documentEdited = YES;
}

- (void) restoreOriginalOrder
{
	[csvDocument.rowController setSortDescriptors:nil];
	[csvDocument changeNumHeaderRows:0];
	[mainWindowController didRestoreOriginalOrder];
	
	self.dataIsAtOriginalOrder = YES;
}

- (BOOL) hasAnyDataAtRow:(NSUInteger)rowIndex
{
	CSVRow *desiredRow = [csvDocument rowAtIndex:rowIndex];
	if (desiredRow) {
		return ![desiredRow isEmptyRow];
	}
	
	return NO;
}

- (BOOL) hasDataAtRow:(NSUInteger)rowIndex forColumnKey:(NSString *)columnKey
{
	CSVRow *desiredRow = [csvDocument rowAtIndex:rowIndex];
	if (desiredRow) {
		return (nil != [desiredRow valueForColumnKey:columnKey]);
	}
	
	return NO;
}

- (void) abortImport
{
	if (!documentLoaded) {
		csvDocument.mustAbortImport = YES;
	}
}

- (void) setColumnOrder:(NSArray *)newOrder
{
	[csvDocument setColumnOrderByKeys:newOrder];
	self.documentEdited = YES;
}
#pragma mark -



#pragma mark Calculations
- (void) performCalculationWithArgs:(NSDictionary *)args				// designed to run in a separate thread
{
	NSAutoreleasePool* myAutoreleasePool = [[NSAutoreleasePool alloc] init];
	
	NSString *sourceKey = [args objectForKey:@"sourceKey"];
	NSString *targetKey = [args objectForKey:@"targetKey"];
	
	NSString *regExp = [args objectForKey:@"regExp"];
	NSString *expression = [args objectForKey:@"expression"];
	
	
	// *****
	// compose the operation string (from "$1 * $2 / ($2 + $3)" to "XX * XX / (XX + XX)" >> [1, 2, 2, 3])
	NSMutableArray *operationStrings = [NSMutableArray array];
	NSMutableArray *operationCaptures = [NSMutableArray array];
	NSInteger i;
	
	NSScanner *scanner = [NSScanner scannerWithString:expression];
	while (NO == [scanner isAtEnd]) {
		NSMutableString *operationString = [NSMutableString string];
		NSString *tempString;
		if ([scanner scanUpToString:@"$" intoString:&tempString]) {
			[operationString appendString:tempString];
		}
		
		// found a Dollar sign "$"
		if ([scanner scanString:@"$" intoString:nil]) {
			[operationString appendString:@"XX"];
			[scanner scanInt:&i];
			
			// remember which RegExp-Match we want here
			[operationCaptures addObject:[NSNumber numberWithInt:i]];
		}
		
		// add to stack
		[operationStrings addObject:[operationString copy]];
	}
	
	
	// *****
	// walk the data and perform the calculation
	NSArray *dataArr = [csvDocument.rowController arrangedObjects];
	NSUInteger numRows = [dataArr count];
	NSEnumerator *walker = [dataArr objectEnumerator];
	CSVRow *row;
	
	NSUInteger captureCount = [NSString captureCountForRegex:regExp];
	NSUInteger operationCapturesCount = [operationCaptures count];
	
	
	// loop rows
	NSUInteger currentIndex = 0;
	while (row = [walker nextObject]) {
		
		// should we stop?
		if (calculationShouldTerminate) {
			break;
		}
		
		// cell value
		NSString *cellString = [row valueForColumnKey:sourceKey];
		if (nil == cellString) {
			continue;
		}
		
		// create the evaluation
		NSMutableString *evaluation = [NSMutableString string];
		NSUInteger c;
		for (c = 0; c < [operationStrings count]; c++) {
			NSInteger captureIndex = (c < operationCapturesCount) ? [[operationCaptures objectAtIndex:c] intValue] : -1;
			if ((captureIndex > 0) && (captureIndex <= captureCount)) {
				NSString *matchedString = [cellString stringByMatching:regExp capture:captureIndex];
				if (NULL != matchedString) {
					[evaluation appendString:[[operationStrings objectAtIndex:c] stringByReplacingOccurrencesOfString:@"XX" withString:matchedString]];
				}
			}
			else {
				[evaluation appendString:[operationStrings objectAtIndex:c]];
			}
		}
		
		// detach to 'bc'
		NSString *result = [BC performMathOperation:evaluation];
		if (result) {
			[row setValue:result forColumnKey:targetKey];
		}
		//NSLog(@"evaluation evaluates to: %@ which results in %@", evaluation, result);
		
		// show progress
		if (0 == currentIndex % 20) {
			NSNumber *alreadyDone = [NSNumber numberWithDouble:(double)((float)(currentIndex + 1) / (float)numRows) * 100];		// progress bar goes from 0 to 100
			[mainWindowController performSelectorOnMainThread:@selector(updateCalculationStatus:)
												   withObject:alreadyDone				// alreadyDone is automatically retained until selector has finished
												waitUntilDone:NO];
		}
		
		currentIndex++;
	}
	
	// finish
	[mainWindowController performSelectorOnMainThread:@selector(updateCalculationStatus:)
										   withObject:[NSNumber numberWithDouble:100.00]
										waitUntilDone:NO];
	self.documentEdited = YES;
	[myAutoreleasePool release];
}
#pragma mark -



#pragma mark Clipboard
- (NSArray *) writablePasteboardTypes
{
    return [NSArray arrayWithObjects:NSFilesPromisePboardType, NSRTFPboardType, NSStringPboardType, nil];		// NSFilenamesPboardType, @"SFVNativePBMetaDataPBType08", @"SFVNativePBClassesListPBType08", @"SFVNativePBObject08"
}


// TODO: put into PPStringFormat
- (NSArray *) fileSuffixesForFormat:(PPStringFormat *)format
{
	NSArray *suffixes = nil;
	/*
	// switch formats
	switch(format) {
		case 1:									// Tab
			suffixes = [NSArray arrayWithObjects:@"csv", @"txt", nil];
			break;
			
		case 2:									// LaTeX
			suffixes = [NSArray arrayWithObject:@"tex"];
			break;
			
		default:								// CSV
			suffixes = [NSArray arrayWithObject:@"csv"];
			break;
	}
	*/
	return suffixes;
}


- (BOOL) copySelectionToPasteboard:(NSPasteboard *)pboard forTypes:(NSArray *)types
{
    BOOL result = NO;
    NSMutableArray *typesToDeclare = [NSMutableArray array];
    NSArray *writableTypes = [self writablePasteboardTypes];
    NSEnumerator *walker = [writableTypes objectEnumerator];
    NSString *type;
    
	// use only the types we're able to provide
    while (type = [walker nextObject]) {
        if ([types containsObject:type]) {
			[typesToDeclare addObject:type];
		}
    }
	
	// copy
    if ([typesToDeclare count] > 0) {
        [pboard declareTypes:typesToDeclare owner:self];
        walker = [typesToDeclare objectEnumerator];
        while (type = [walker nextObject]) {
            if ([self copySelectionToPasteboard:pboard type:type]) {
				result = YES;
			}
        }
    }
	
    return result;
}

- (BOOL) copySelectionToPasteboard:(NSPasteboard *)pboard type:(NSString *)type
{
	BOOL result = NO;
	
	// we want a file - provide the file extension
	if ([type isEqualToString:NSFilesPromisePboardType]) {
		result = [pboard setPropertyList:[self fileSuffixesForFormat:self.documentFormat] forType:NSFilesPromisePboardType];
	}
	
	// we want a filename - only write to file when actually requested (pasteboard:provideDataForType:)
	//	else if ([type isEqualToString:NSFilenamesPboardType]) {
	//		result = YES;
	//	}
	
	// ---
	else if ([type isEqualToString:@"SFVNativePBClassesListPBType08"]) {
		NSString *string = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<array>\n	<string>SFTTableInfo</string>\n	<string>SFWPStorage</string>\n	<string>SFTTableInfo</string>\n</array>\n</plist>\n";
		result = [pboard setString:string forType:@"SFVNativePBClassesListPBType08"];
	}
	else if ([type isEqualToString:@"SFVNativePBMetaDataPBType08"]) {
		NSString *string = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n	<key>SFVHasPrintableText</key>\n	<true/>\n	<key>SFVHasTable</key>\n	<true/>\n	<key>SFVHasText</key>\n	<true/>\n</dict>\n</plist>\n";
		result = [pboard setString:string forType:@"SFVNativePBMetaDataPBType08"];
	}
	
	else if ([type isEqualToString:@"SFVNativePBObject08"]) {
		NSString *string = @"<?xml version=\"1.0\"?>\n		<ls:copied-data xmlns:sfa=\"http://developer.apple.com/namespaces/sfa\" xmlns:sf=\"http://developer.apple.com/namespaces/sf\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:ls=\"http://developer.apple.com/namespaces/ls\" ls:version=\"72007061400\" sfa:ID=\"SFVPasteboardObject-0\" sf:application-name=\"Numbers 1.0.2\">\n		<sf:text sfa:ID=\"SFWPStorage-0\" sf:kind=\"cell\" sf:excl=\"Y\" sf:class=\"text-storage\">\n		<sf:text-body>\n		<sf:layout sf:style=\"tabular-Basic-body-cell-layout-style-id\">\n		<sf:p sf:style=\"tabular-Basic-body-cell-paragraph-style-id\">aaa<sf:tab/>bbb<sf:tab/>ccc<sf:br/>\n		</sf:p>\n		<sf:p sf:style=\"tabular-Basic-body-cell-paragraph-style-id\">111<sf:tab/>222<sf:tab/>333</sf:p>\n		</sf:layout>\n		</sf:text-body>\n		</sf:text>\n		</ls:copied-data>";
		result = [pboard setString:string forType:@"SFVNativePBObject08"];
	}
	// ---
	
	// RTF
	else if ([type isEqualToString:NSRTFPboardType]) {
		NSAttributedString *attributedString = [[[NSAttributedString alloc] initWithString:[self stringInFormat:[PPStringFormat tabFormat] allRows:NO allColumns:NO]] autorelease];
		if (attributedString && [attributedString length] > 0) {
			result = [pboard setData:[attributedString RTFFromRange:NSMakeRange(0, [attributedString length]) documentAttributes:nil] forType:NSRTFPboardType];
		}
	}
	
	// Plain Text
	else if ([type isEqualToString:NSStringPboardType]) {
		NSString *string = [self stringInFormat:self.documentFormat allRows:NO allColumns:NO];
		if (string && [string length] > 0) {
			result = [pboard setString:string forType:NSStringPboardType];
		}
	}
	
	return result;
}

- (void) pasteboard:(NSPasteboard *)pboard provideDataForType:(NSString *)type
{
	// We expect that -tableView:namesOfPromisedFilesDroppedAtDestination:forDraggedRowsWithIndexes: will usually be called instead,
	// but we implement this method to create a file if NSFilenamesPboardType is ever requested directly
	if ([type isEqualToString:NSFilenamesPboardType]) {
		NSURL *myFileURL = [NSURL URLWithString:[@"~/Desktop" stringByExpandingTildeInPath]];
		NSError *error;
		if ([self writeToURL:myFileURL ofType:nil error:&error]) {
			[pboard setPropertyList:[NSArray arrayWithObject:[myFileURL path]] forType:NSFilenamesPboardType];
		}
	}
}

- (void) copy:(id)sender
{
	[self copySelectionToPasteboard:[NSPasteboard generalPasteboard] forTypes:[self writablePasteboardTypes]];
}
#pragma mark -



#pragma mark Document Based Musts
- (NSString *) windowNibName
{
    return @"MyDocument";
}

- (void) makeWindowControllers
{
	mainWindowController = [[[CSVWindowController alloc] initWithWindowNibName:[self windowNibName]] autorelease];
	[self addWindowController:mainWindowController];
}


@end
