//
//  MyDocument.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 21.02.08.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import "MyDocument.h"
#import "CSVWindowController.h"
#import "CSVDocument.h"
#import "CSVRow.h"
#import "CSVColumn.h"
#import "PPStringFormat.h"
#import "PPStringFormatManager.h"
#import "CSVInspector.h"

#import "DataTableView.h"
#import "DataTableColumn.h"
#import "DataTableHeaderCell.h"
#import "RegexKitLite.h"
#import "BC.h"


#define EXPRESSION_MAX_LEN 1023
#define kColumnHeaderNameKey @"name"
#define kColumnHeaderTypeKey @"type"
#define kColumnHeaderActiveKey @"active"



@interface MyDocument ()

@property (nonatomic, readwrite, retain) CSVWindowController *mainWindowController;

- (void) detachStringParsing:(NSString *)string;

@end



@implementation MyDocument

@synthesize mainWindowController;
@synthesize fileEncoding;
@synthesize csvDocument;
@synthesize documentLoaded;
@dynamic dataIsAtOriginalOrder;
@synthesize exportHeaders;
@synthesize calculationShouldTerminate;
@synthesize importFormat;
@dynamic exportFormat;


#pragma mark - Generic
- (id)init
{
	self = [super init];
	if (nil != self) {
		exportHeaders = YES;
		documentLoaded = YES;				// will be set to know when we got instantiated by reading from URL
		dataIsAtOriginalOrder = YES;
		
		self.csvDocument = [CSVDocument csvDocument];
		csvDocument.delegate = self;
		csvDocument.document = self;
	}
	
    return self;
}

- (void)dealloc
{
	self.mainWindowController = nil;
	self.csvDocument = nil;
	self.importFormat = nil;
	self.exportFormat = nil;
 	
	[super dealloc];
}



#pragma mark - KVC
- (BOOL)dataIsAtOriginalOrder
{
	return dataIsAtOriginalOrder;
}
- (void)setDataIsAtOriginalOrder:(BOOL)flag
{
	if (flag != dataIsAtOriginalOrder) {
		[self willChangeValueForKey:@"dataIsAtOriginalOrder"];
		dataIsAtOriginalOrder = flag;
		[self didChangeValueForKey:@"dataIsAtOriginalOrder"];
	}
}

- (PPStringFormat *)exportFormat
{
	if (nil == exportFormat) {
		self.exportFormat = [PPStringFormat csvFormat];
	}
	
	return exportFormat;
}
- (void)setExportFormat:(PPStringFormat *)newFormat
{
	if (newFormat != exportFormat) {
		[exportFormat release];
		exportFormat = [newFormat retain];
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
	// an export format was loaded -> install
	if ([typeName isEqualToString:@"Export Format"]) {
		if ([[PPStringFormatManager sharedManager] installFormat:absoluteURL error:outError]) {
			[PPStringFormatManager show:nil];
			return YES;
		}
	}
	
	// a csv/tsv document was opened -> parse
	else {
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
					[self presentError:(outError ? *outError : NULL)];
					
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
	return NO;
}

- (void) detachStringParsing:(NSString *)string
{
	NSAutoreleasePool *detachPool = [[NSAutoreleasePool alloc] init];
	NSError *error;
	
	csvDocument.autoDetectSeparator = YES;
	if ([csvDocument parseCSVString:string maxRows:0 error:&error]) {
		self.importFormat = [PPStringFormat csvFormat];
	}
	else {
		[self presentError:error];
	}
	
	[detachPool release];
}
#pragma mark -



#pragma mark CSVDocument Delegate
// The parsing delegate methods will be called from and run on the separate thread created in "detachStringParsing:" !!
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
	
	[mainWindowController performSelectorOnMainThread:@selector(setProgressSheetIndeterminate:)
										   withObject:[NSNumber numberWithBool:YES]
										waitUntilDone:NO];
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

- (void) csvDocumentDidChangeColumnNames:(CSVDocument *)document
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:kDocumentDidChangeColumns object:self];
}

- (void) csvDocumentDidChangeNumColumns:(CSVDocument *)document
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:kDocumentDidChangeColumns object:self];
}
#pragma mark -



#pragma mark Saving Files
// the save-a-file sequence
//	saveDocument:								<< NSDocument >>
//	writeToURL:ofType:error:					<< NSDocument >>
//	fileWrapperOfType:error:					<< NSDocument >>
//	writeToFile:atomically:updateFilenames:		<< NSFileWrapper >>

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	PPStringFormat *thisFormat = self.exportFormat;
	if ([typeName isEqualToString:@"csv"]) {
		thisFormat = self.importFormat;
	}
	
	BOOL success = NO;
	
	// get the string
	NSString *finalString = [self stringInFormat:thisFormat allRows:YES allColumns:YES error:outError];
	if (!outError || nil == *outError) {
		
		// save the file
		success = [finalString writeToURL:absoluteURL atomically:YES encoding:NSUTF8StringEncoding error:outError];
		if (!success) {
			NSLog(@"Error while saving: %@", [*outError localizedDescription]);
		}
	}
	else {
		NSLog(@"Error while saving: %@", [*outError localizedDescription]);
	}
	
	return success;
}

- (NSString *) stringInFormat:(PPStringFormat *)format allRows:(BOOL)allRows allColumns:(BOOL)allColumns error:(NSError **)outError;
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
		columns = [NSMutableArray array];
		for (CSVColumn *column in csvDocument.columns) {
			if (column.active) {
				[(NSMutableArray *)columns addObject:column];
			}
		}
	}
	
	// TODO: Export headers -> other way of setting exportHeaders desired
	return [csvDocument stringInFormat:format withColumns:columns forRowIndexes:rowIndexes includeHeaders:exportHeaders error:outError];
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
	else {
		[mainWindowController hideProgressSheet];
	}
}
#pragma mark -



#pragma mark Calculations
- (void) performCalculationWithArgs:(NSDictionary *)args				// designed to run in a separate thread
{
	NSAutoreleasePool* myAutoreleasePool = [[NSAutoreleasePool alloc] init];
	
	NSString *sourceKey = [args objectForKey:kCalculationKeySourceColumn];
	NSString *targetKey = [args objectForKey:kCalculationKeyTargetColumn];
	
	NSString *regExp = [args objectForKey:kCalculationKeySourceRegEx];
	NSString *expression = [args objectForKey:kCalculationKeyTargetExpression];
	
	
	// *****
	// parse unique match numbers (from "$1 * $2 / ($2 + $3)"  ==>  [1, 2, 3])
	NSMutableArray *matchIndexes = [NSMutableArray array];
	NSInteger i;
	
	NSScanner *scanner = [NSScanner scannerWithString:expression];
	while (![scanner isAtEnd]) {
		[scanner scanUpToString:@"$" intoString:NULL];
		
		// found a Dollar sign "$"
		if ([scanner scanString:@"$" intoString:NULL]) {
			[scanner scanInteger:&i];
			
			// add to the collection if not already there
			NSNumber *iNum = [NSNumber numberWithInt:i];
			if (![matchIndexes containsObject:iNum]) {
				[matchIndexes addObject:iNum];
			}
		}
	}
	
	
	// *****
	// walk the data and perform the calculation
	NSArray *rowArr = [csvDocument arrangedRows];
	NSUInteger numRows = [rowArr count];
	
	// loop rows
	NSUInteger currentIndex = 0;
	for (CSVRow *row in rowArr) {
		
		// should we stop?
		if (calculationShouldTerminate) {
			break;
		}
		
		// get cell value
		NSString *cellString = [row valueForColumnKey:sourceKey];
		if (nil == cellString) {
			continue;
		}
		
		// get matches
		NSArray *fullMatches = [cellString arrayOfCaptureComponentsMatchedByRegex:regExp];
		if ([fullMatches count] < 1) {
			continue;
		}
		NSArray *matches = [fullMatches objectAtIndex:0];
		NSUInteger num_matches = [matches count];
		if (num_matches > 0) {
			NSMutableString *evalString = [expression mutableCopy];
			NSRange fullRange;
			
			for (NSNumber *iNum in matchIndexes) {
				NSUInteger i = [iNum unsignedIntValue];
				if (i < num_matches) {
					NSString *match = [matches objectAtIndex:i];
					fullRange = NSMakeRange(0, [evalString length]);
					
					[evalString replaceOccurrencesOfString:[NSString stringWithFormat:@"$%lu", (unsigned long)i]
												withString:match
												   options:0
													 range:fullRange];
				}
			}
			
			// detach to 'bc'
			// TODO: This is slow as hell!
			NSString *result = [BC performMathOperation:evalString];
			if (result) {
				[row setValue:result forColumnKey:targetKey];
			}
		}
		
		// show progress and clean the pool
		if (0 == currentIndex % 20) {
			NSNumber *alreadyDone = [NSNumber numberWithDouble:(double)(currentIndex + 1) / numRows];
			[[CSVInspector sharedInspector] performSelectorOnMainThread:@selector(updateCalculationStatus:)
															 withObject:alreadyDone			// will be retained as long as necessary
														  waitUntilDone:NO];
		}
		
		currentIndex++;
	}
	
	// finish
	[[CSVInspector sharedInspector] performSelectorOnMainThread:@selector(updateCalculationStatus:)
													 withObject:[NSNumber numberWithInt:1]
												  waitUntilDone:NO];
	[myAutoreleasePool release];
}



#pragma mark - Clipboard
- (NSArray *)writablePasteboardTypes
{
    return [NSArray arrayWithObjects:NSFilesPromisePboardType, NSRTFPboardType, NSStringPboardType, nil];		// NSFilenamesPboardType, @"SFVNativePBMetaDataPBType08", @"SFVNativePBClassesListPBType08", @"SFVNativePBObject08"
}


// TODO: put into PPStringFormat
- (NSArray *)fileSuffixesForFormat:(PPStringFormat *)format
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
		result = [pboard setPropertyList:[self fileSuffixesForFormat:self.exportFormat] forType:NSFilesPromisePboardType];
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
		NSAttributedString *attributedString = [[[NSAttributedString alloc] initWithString:[self stringInFormat:[PPStringFormat tabFormat] allRows:NO allColumns:NO error:nil]] autorelease];
		if (attributedString && [attributedString length] > 0) {
			result = [pboard setData:[attributedString RTFFromRange:NSMakeRange(0, [attributedString length]) documentAttributes:nil] forType:NSRTFPboardType];
		}
	}
	
	// Plain Text
	else if ([type isEqualToString:NSStringPboardType]) {
		NSString *string = [self stringInFormat:self.exportFormat allRows:NO allColumns:NO error:nil];
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



#pragma mark Undo Manager
- (BOOL) hasUndoManager
{
	return YES;
}
#pragma mark -



#pragma mark Document Windows
- (void) windowDidBecomeMain:(NSNotification *)notification
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:kDocumentDidBecomeActive object:self];
}

- (void) windowDidResignMain:(NSNotification *)notification
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:kDocumentDidBecomeInactive object:self];
}

- (void) windowWillClose:(NSNotification *)notification
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:kDocumentDidBecomeInactive object:self];
}


- (NSString *) windowNibName
{
    return @"MyDocument";
}

- (void) makeWindowControllers
{
	self.mainWindowController = [[[CSVWindowController alloc] initWithWindowNibName:[self windowNibName]] autorelease];
	[self addWindowController:mainWindowController];
}


@end
