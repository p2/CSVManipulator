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

#define kColumnKeyMask @"col_%i"			// must containt one integer placeholder (%i or %d) !

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
	
	BOOL parseSuccessful;
	BOOL autoDetectSeparator;			// if YES will check for other separators (";" and TAB) than the comma
	NSUInteger numHeaderRows;			// first x rows contain header data
	
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
@property (nonatomic, assign) NSUInteger numHeaderRows;

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

// row handling
- (CSVRow *) rowAtIndex:(NSUInteger)rowIndex;
- (void) changeNumHeaderRows:(NSUInteger)newNum;
- (void) rearrangeRows;
- (void) row:(CSVRow *)thisRow didBecomeHeaderRow:(BOOL)itDid;

// utils
- (NSString *) nextAvailableColumnKey;


@end
