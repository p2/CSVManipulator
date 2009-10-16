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
@class CSVRow;
@class CSVColumn;
@class PPStringFormat;


@interface CSVDocument : NSObject {
	id <CSVDocumentDelegate> delegate;
	NSString *separator;
	
	NSMutableArray *rows;
	NSNumber *numRows;
	
#ifndef IPHONE
	CSVRowController *rowController;
#endif
	
	NSArray *columns;					// needs to be an array to preserve column order
	NSDictionary *columnDict;			// readonly to allow fast access to columns by key
	
	BOOL parseSuccessful;
	BOOL autoDetectSeparator;			// if YES will check for other separators (";" and TAB) than the comma
	NSUInteger numHeaderRows;			// first x rows contain header data
	
	BOOL mustAbortImport;
	BOOL didAbortImport;
	BOOL reportEveryRowParsed;			// if YES informs the delegate after each row that was parsed
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSString *separator;

@property (nonatomic, retain) NSMutableArray *rows;
@property (nonatomic, copy) NSNumber *numRows;
#ifndef IPHONE
@property (nonatomic, retain) CSVRowController *rowController;
#endif

@property (nonatomic, retain) NSArray *columns;
@property (nonatomic, readonly, retain) NSDictionary *columnDict;

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
- (NSString *) stringInFormat:(PPStringFormat *)format withColumns:(NSArray *)columnArray forRowIndexes:(NSIndexSet *)rowIndexes includeHeaders:(BOOL)headerFlag;
#endif

// column handling
- (void) addColumn:(CSVColumn *) newColumn;
- (BOOL) isFirstColumnKey:(NSString *)columnKey;
- (BOOL) hasColumnKey:(NSString *)columnKey;
- (void) setColumnOrderByKeys:(NSArray *)newOrderKeys;

- (CSVColumn *) columnWithKey:(NSString *)columnKey;
- (NSString *) nameForColumnKey:(NSString *)columnKey;
- (NSString *) nameForColumnKey:(NSString *)columnKey quoted:(BOOL)quoted;
- (void) setHeaderName:(NSString *)newName forColumnKey:(NSString *)columnKey;
- (void) setHeaderActive:(BOOL)active forColumnKey:(NSString *)columnKey;

// row handling
- (CSVRow *) rowAtIndex:(NSUInteger)rowIndex;
- (void) changeNumHeaderRows:(NSUInteger)newNum;
- (void) rearrangeRows;
- (void) row:(CSVRow *)thisRow didBecomeHeaderRow:(BOOL)itDid;


@end
