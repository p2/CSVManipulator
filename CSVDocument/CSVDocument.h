//
//  CSVDocument.h
//  QuickLookCSV
//
//  Created by Pascal Pfiffner on 03.07.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//  

#import <Cocoa/Cocoa.h>
@class CSVRow;
@class CSVColumn;
@class CSVRowController;


@interface CSVDocument : NSObject {
	NSString *separator;
	
	CSVRow *headerRow;			// must never be nil
	NSMutableArray *rows;
	NSNumber *numRows;
	CSVRowController *rowController;
	
	NSArray *columns;
	NSDictionary *columnDict;
	
	BOOL autoDetectSeparator;			// if YES will check for other separators (";" and TAB) than the comma
	BOOL firstRowIsHeaderRow;			// tells us whether the first row contains data or only header info. bound to a checkbox
}

@property (nonatomic, retain) NSString *separator;

@property (nonatomic, copy) CSVRow *headerRow;
@property (nonatomic, retain) NSMutableArray *rows;
@property (nonatomic, copy) NSNumber *numRows;
@property (nonatomic, retain) CSVRowController *rowController;

@property (nonatomic, retain) NSArray *columns;
@property (nonatomic, readonly) NSDictionary *columnDict;


@property (nonatomic, assign) BOOL autoDetectSeparator;
@property (nonatomic, assign) BOOL firstRowIsHeaderRow;

+ (id) csvDocument;
- (BOOL) parseCSVString:(NSString *)string error:(NSError **)error;
- (BOOL) parseCSVString:(NSString *)string maxRows:(NSUInteger)maxRows error:(NSError **)error;

- (void) changeHeaderRow:(CSVRow *)newHeaderRow;
- (BOOL) isFirstColumnKey:(NSString *)columnKey;
- (BOOL) hasColumnKey:(NSString *)columnKey;

- (NSString *) nameForColumn:(NSString *)columnKey;
- (NSString *) nameForColumn:(NSString *)columnKey quoted:(BOOL)quoted;
- (void) setHeaderName:(NSString *)newName forColumnKey:(NSString *)columnKey;
- (void) setHeaderActive:(BOOL)active forColumnKey:(NSString *)columnKey;

- (CSVRow *) rowAtIndex:(NSUInteger)rowIndex;

- (NSString *) stringInFormat:(NSUInteger)format withColumns:(NSArray *)columnArray forRowIndexes:(NSIndexSet *)rowIndexes writeHeader:(BOOL)headerFlag;


@end
