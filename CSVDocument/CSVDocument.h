//
//  CSVDocument.h
//  QuickLookCSV
//
//  Created by Pascal Pfiffner on 03.07.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//  

#ifdef IPHONE
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
@class CSVRowController;
#endif

#import "CSVDocumentDelegate.h"

#define kColumnKeyMask @"col_%lu"			// must contain one int/long placeholder

@class CSVRow;
@class CSVColumn;
@class PPStringFormat;


@interface CSVDocument : NSObject {
	id <CSVDocumentDelegate> delegate;
	NSDocument *document;					// we're keeping NSDocument separate from CSVDocument
	NSString *separator;
	
	NSMutableArray *rows;
	NSNumber *numRows;
	
#ifndef IPHONE
	CSVRowController *rowController;
#endif
	
	NSMutableArray *columns;			// needs to be an array to preserve column order
	NSMutableDictionary *columnDict;	// readonly to allow fast access to columns by key
	
	NSUInteger parseNumHeaderRows;		// if set before parsing, the first x rows will be header rows
	BOOL parseSuccessful;
	BOOL autoDetectSeparator;			// NO by default. If YES will check for other separators (";", TAB and "|") than the comma
	
	BOOL mustAbortImport;
	BOOL didAbortImport;
	BOOL reportEveryRowParsed;			// if YES informs the delegate after each row that was parsed
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) NSDocument *document;
@property (nonatomic, retain) NSString *separator;

@property (nonatomic, retain) NSMutableArray *rows;
@property (nonatomic, copy) NSNumber *numRows;
#ifndef IPHONE
@property (nonatomic, retain) CSVRowController *rowController;
#endif

@property (nonatomic, retain) NSMutableArray *columns;
@property (nonatomic, readonly, retain) NSMutableDictionary *columnDict;
@property (nonatomic, readonly) NSArray *activeColumns;

@property (nonatomic, assign) BOOL parseSuccessful;
@property (nonatomic, assign) BOOL autoDetectSeparator;
@property (nonatomic, assign) NSUInteger parseNumHeaderRows;

@property (assign) BOOL mustAbortImport;
@property (nonatomic, assign) BOOL didAbortImport;
@property (nonatomic, assign) BOOL reportEveryRowParsed;


// Main methods
+ (id) csvDocument;
- (void) setNumRowsWithInt:(NSInteger)num_rows;
- (NSUInteger) numRowsToExpect:(NSString *)string;
- (BOOL) parseCSVString:(NSString *)string error:(NSError **)error;
- (BOOL) parseCSVString:(NSString *)string maxRows:(NSUInteger)maxRows error:(NSError **)error;
#ifdef CSV_STRING_EXPORTING
- (NSString *) stringInFormat:(PPStringFormat *)format
				  withColumns:(NSArray *)columnArray
				forRowIndexes:(NSIndexSet *)rowIndexes
			   includeHeaders:(BOOL)headerFlag
						error:(NSError **)outError;
#endif

// column handling
- (BOOL) addColumn:(CSVColumn *)newColumn;
- (BOOL) removeColumn:(CSVColumn *)oldColumn;
- (CSVColumn *) columnWithKey:(NSString *)columnKey;
- (void) setColumnOrderByKeys:(NSArray *)newOrderKeys;
- (void) setColumnActive:(BOOL)active forColumnKey:(NSString *)columnKey;
- (void) updateColumnNames;

// row handling
- (CSVRow *) rowAtIndex:(NSUInteger)rowIndex;
- (NSUInteger) numHeaderRows;
- (void) changeNumHeaderRows:(NSUInteger)newNum;
- (void) rearrangeRows;
- (NSArray *) arrangedRows;
- (void) row:(CSVRow *)thisRow didBecomeHeaderRow:(BOOL)itDid;
- (void) removeRow:(CSVRow *)row;

// utils
- (NSString *) nextAvailableColumnKey;


@end
