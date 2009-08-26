//
//  CSVRow.h
//  QuickLookCSV
//
//  Created by Pascal Pfiffner on 03.07.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//  

#import <Cocoa/Cocoa.h>
@class CSVDocument;
@class CSVColumn;


@interface CSVRow : NSObject <NSCopying> {
	CSVDocument *document;
	NSMutableDictionary *rowValues;
}

@property (nonatomic, assign) CSVDocument *document;
@property (nonatomic, copy) NSMutableDictionary *rowValues;

+ (id) rowForDocument:(CSVDocument *)forDocument;
+ (id) rowFromDict:(NSMutableDictionary *)dict forDocument:(CSVDocument *)forDocument;

- (NSString *) valuesForColumns:(NSArray *)columns combinedByString:(NSString *)sepString;
- (NSString *) valuesForColumns:(NSArray *)columns combinedByString:(NSString *)sepString quoted:(BOOL)quoteStrings;
- (NSString *) valueForColumn:(CSVColumn *)column;
- (NSString *) valueForColumnKey:(NSString *)columnKey;
- (BOOL) isEmptyRow;

- (void) setValue:(id)value forColumn:(CSVColumn *)column;
- (void) setValue:(id)value forColumnKey:(NSString *)key;


@end
