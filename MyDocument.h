//
//  MyDocument.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 21.02.08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "CSVDocumentDelegate.h"
@class MyWindowController;
@class CSVRow;
@class DataTableView;

@class CSVDocument;


@interface MyDocument : NSDocument <CSVDocumentDelegate>
{
	MyWindowController *mainWindowController;
	
	NSURL *fileURL;
	NSStringEncoding fileEncoding;
	NSString *displayName;
	CSVDocument *csvDocument;
	
	BOOL documentLoaded;
	BOOL nibIsAlive;
	BOOL documentEdited;
	BOOL dataIsAtOriginalOrder;
	NSUInteger numRowsToExpect;
	
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
@property (nonatomic, assign) BOOL exportHeaders;
@property (nonatomic, assign) BOOL calculationShouldTerminate;


// KVC
- (void) setLastChoiceFormat:(NSInteger)format;

// Data control
- (void) awokeFromNib;
- (NSUInteger) numColumns;
- (NSArray *) columns;
- (NSString *) stringInFormat:(NSInteger)format allRows:(BOOL)allRows allColumns:(BOOL)allColumns;			// 0 = csv, 1 = Tab, 2 = LaTeX
- (BOOL) hasAnyDataAtRow:(NSUInteger)rowIndex;
- (BOOL) hasDataAtRow:(NSUInteger)rowIndex forColumnKey:(NSString *)columnKey;

- (void) addToCSVRow:(id)sender;
- (void) removeFromCSVRow:(id)sender;
- (void) restoreOriginalOrder;
- (void) abortImport;

// Clipboard and Files
- (NSArray *) writablePasteboardTypes;
- (NSArray *) fileSuffixesForFormat:(NSInteger)format;
- (BOOL) copySelectionToPasteboard:(NSPasteboard *)pboard forTypes:(NSArray *)types;
- (BOOL) copySelectionToPasteboard:(NSPasteboard *)pboard type:(NSString *)type;
- (void) pasteboard:(NSPasteboard *)pboard provideDataForType:(NSString *)type;
- (void) copy:(id)sender;

// calculations
- (void) performCalculationWithArgs:(NSDictionary *)args;


@end
