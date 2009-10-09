//
//  CSVRow.h
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
#endif

@class CSVDocument;
@class CSVColumn;


@interface CSVRow : NSObject <NSCopying> {
	CSVDocument *document;
	NSMutableDictionary *rowValues;
	BOOL isHeaderRow;
}

@property (nonatomic, assign) CSVDocument *document;
@property (nonatomic, copy) NSMutableDictionary *rowValues;
@property (nonatomic, assign) BOOL isHeaderRow;

+ (id) rowForDocument:(CSVDocument *)forDocument;
+ (id) rowFromDict:(NSMutableDictionary *)dict forDocument:(CSVDocument *)forDocument;

- (NSArray *) valuesForColumns:(NSArray *)columns;
- (NSArray *) valuesForColumnKeys:(NSArray *)columnKeys;
- (NSString *) valuesForColumns:(NSArray *)columns combinedByString:(NSString *)sepString;
- (NSString *) valuesForColumns:(NSArray *)columns combinedByString:(NSString *)sepString quoted:(BOOL)quoteStrings;
- (NSString *) valueForColumn:(CSVColumn *)column;
- (NSString *) valueForColumnKey:(NSString *)columnKey;
- (BOOL) valueForColumnIsEmpty:(CSVColumn *)column;
- (BOOL) valueForColumnKeyIsEmpty:(NSString *)columnKey;
- (BOOL) isEmptyRow;

- (void) setValue:(id)value forColumn:(CSVColumn *)column;
- (void) setValue:(id)value forColumnKey:(NSString *)key;


@end
