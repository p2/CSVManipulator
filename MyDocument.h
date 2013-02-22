//
//  MyDocument.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 21.02.08.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//


#import <Cocoa/Cocoa.h>
#import "CSVDocumentDelegate.h"
@class CSVWindowController;
@class CSVDocument;
@class CSVRow;
@class PPStringFormat;
@class DataTableView;

#define kDocumentDidBecomeActive @"CSVManip_DocumentDidBecomeActive"
#define kDocumentDidBecomeInactive @"CSVManip_DocumentDidBecomeInactive"
#define kDocumentDidChangeColumns @"CSVManip_DocumentDidChangeColumns"

#define kCalculationKeySourceColumn @"CSVManip_CalcSourceColumn"
#define kCalculationKeyTargetColumn @"CSVManip_CalcTargetColumn"
#define kCalculationKeySourceRegEx @"CSVManip_CalcSourceRegEx"
#define kCalculationKeyTargetExpression @"CSVManip_CalcTargetExpression"


@interface MyDocument : NSDocument <CSVDocumentDelegate>
{
	CSVWindowController *mainWindowController;
	
	NSStringEncoding fileEncoding;
	CSVDocument *csvDocument;
	
	BOOL documentLoaded;
	BOOL dataIsAtOriginalOrder;
	NSUInteger numRowsToExpect;
	PPStringFormat *importFormat;
	PPStringFormat *exportFormat;
	
	BOOL exportHeaders;								// bound to a checkbox, tells us whether to export the header on save or not
	NSInteger lastChoiceExportFormat;				// read from prefs
	
	BOOL calculationShouldTerminate;
}

@property (nonatomic, readonly, retain) CSVWindowController *mainWindowController;

@property (nonatomic, assign) NSStringEncoding fileEncoding;
@property (nonatomic, retain) CSVDocument *csvDocument;

@property (nonatomic, assign) BOOL documentLoaded;
@property (nonatomic, assign) BOOL dataIsAtOriginalOrder;
@property (nonatomic, retain) PPStringFormat *importFormat;
@property (nonatomic, retain) PPStringFormat *exportFormat;

@property (nonatomic, assign) BOOL exportHeaders;
@property (assign) BOOL calculationShouldTerminate;


// Data control
- (NSUInteger) numColumns;
- (NSArray *) columns;
- (NSString *) stringInFormat:(PPStringFormat *)format allRows:(BOOL)allRows allColumns:(BOOL)allColumns error:(NSError **)outError;
- (BOOL) hasAnyDataAtRow:(NSUInteger)rowIndex;
- (BOOL) hasDataAtRow:(NSUInteger)rowIndex forColumnKey:(NSString *)columnKey;

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

// window notifications
- (void) windowDidBecomeMain:(NSNotification *)notification;
- (void) windowDidResignMain:(NSNotification *)notification;
- (void) windowWillClose:(NSNotification *)notification;


@end
