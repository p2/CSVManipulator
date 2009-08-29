//
//  MyDocument.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 21.02.08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "CSVDocumentDelegate.h"
@class CSVWindowController;
@class CSVDocument;
@class CSVRow;
@class PPExportFormat;
@class DataTableView;



@interface MyDocument : NSDocument <CSVDocumentDelegate>
{
	CSVWindowController *mainWindowController;
	
	NSURL *fileURL;
	NSStringEncoding fileEncoding;
	NSString *displayName;
	CSVDocument *csvDocument;
	
	BOOL documentLoaded;
	BOOL documentEdited;
	BOOL dataIsAtOriginalOrder;
	NSUInteger numRowsToExpect;
	PPExportFormat *documentFormat;
	
	BOOL exportHeaders;								// bound to a checkbox, tells us whether to export the header on save or not
	NSInteger lastChoiceExportFormat;
	
	BOOL calculationShouldTerminate;
}


@property (nonatomic, retain) NSURL *fileURL;
@property (nonatomic, assign) NSStringEncoding fileEncoding;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) CSVDocument *csvDocument;

@property (nonatomic, assign) BOOL documentLoaded;
@property (nonatomic, assign, getter=isDocumentEdited) BOOL documentEdited;
@property (nonatomic, assign) BOOL dataIsAtOriginalOrder;
@property (nonatomic, retain) PPExportFormat *documentFormat;

@property (nonatomic, assign) BOOL exportHeaders;
@property (nonatomic, assign) BOOL calculationShouldTerminate;


// Data control
- (NSUInteger) numColumns;
- (NSArray *) columns;
- (NSString *) stringInFormat:(PPExportFormat *)format allRows:(BOOL)allRows allColumns:(BOOL)allColumns;			// 0 = csv, 1 = Tab, 2 = LaTeX
- (BOOL) hasAnyDataAtRow:(NSUInteger)rowIndex;
- (BOOL) hasDataAtRow:(NSUInteger)rowIndex forColumnKey:(NSString *)columnKey;

- (void) addToCSVRow:(id)sender;
- (void) removeFromCSVRow:(id)sender;
- (void) restoreOriginalOrder;
- (void) abortImport;

// Clipboard and Files
- (NSArray *) writablePasteboardTypes;
- (NSArray *) fileSuffixesForFormat:(PPExportFormat *)format;
- (BOOL) copySelectionToPasteboard:(NSPasteboard *)pboard forTypes:(NSArray *)types;
- (BOOL) copySelectionToPasteboard:(NSPasteboard *)pboard type:(NSString *)type;
- (void) pasteboard:(NSPasteboard *)pboard provideDataForType:(NSString *)type;
- (void) copy:(id)sender;

// calculations
- (void) performCalculationWithArgs:(NSDictionary *)args;


@end
