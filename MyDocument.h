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
@class PPStringFormat;
@class DataTableView;



@interface MyDocument : NSDocument <CSVDocumentDelegate>
{
	CSVWindowController *mainWindowController;
	
	NSStringEncoding fileEncoding;
	CSVDocument *csvDocument;
	
	BOOL documentLoaded;
	BOOL documentEdited;
	BOOL dataIsAtOriginalOrder;
	NSUInteger numRowsToExpect;
	PPStringFormat *exportFormat;
	
	BOOL exportHeaders;								// bound to a checkbox, tells us whether to export the header on save or not
	NSInteger lastChoiceExportFormat;
	
	BOOL calculationShouldTerminate;
}

@property (nonatomic, readonly, retain) CSVWindowController *mainWindowController;

@property (nonatomic, assign) NSStringEncoding fileEncoding;
@property (nonatomic, retain) CSVDocument *csvDocument;

@property (nonatomic, assign) BOOL documentLoaded;
@property (assign, getter=isDocumentEdited) BOOL documentEdited;
@property (nonatomic, assign) BOOL dataIsAtOriginalOrder;
@property (nonatomic, retain) PPStringFormat *exportFormat;

@property (nonatomic, assign) BOOL exportHeaders;
@property (nonatomic, assign) BOOL calculationShouldTerminate;


// Data control
- (NSUInteger) numColumns;
- (NSArray *) columns;
- (NSString *) stringInFormat:(PPStringFormat *)format allRows:(BOOL)allRows allColumns:(BOOL)allColumns;			// 0 = csv, 1 = Tab, 2 = LaTeX
- (BOOL) hasAnyDataAtRow:(NSUInteger)rowIndex;
- (BOOL) hasDataAtRow:(NSUInteger)rowIndex forColumnKey:(NSString *)columnKey;

- (void) addCSVRow:(id)sender;
- (void) removeCSVRow:(id)sender;
- (void) restoreOriginalOrder;
- (void) abortImport;

// Clipboard and Files
- (NSArray *) writablePasteboardTypes;
- (NSArray *) fileSuffixesForFormat:(PPStringFormat *)format;
- (BOOL) copySelectionToPasteboard:(NSPasteboard *)pboard forTypes:(NSArray *)types;
- (BOOL) copySelectionToPasteboard:(NSPasteboard *)pboard type:(NSString *)type;
- (void) pasteboard:(NSPasteboard *)pboard provideDataForType:(NSString *)type;
- (void) copy:(id)sender;

// calculations
- (void) performCalculationWithArgs:(NSDictionary *)args;


@end
