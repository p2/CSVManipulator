//
//  CSVDocumentDelegate.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 26.08.09.
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
@class CSVRow;


@protocol CSVDocumentDelegate <NSObject>

@optional

- (void) csvDocumentDidParseString:(CSVDocument *)document;
- (void) csvDocument:(CSVDocument *)document didParseNumRows:(NSUInteger)num_parsed;
- (void) csvDocument:(CSVDocument *)document didParseRow:(CSVRow *)row;

- (void) csvDocument:(CSVDocument *)document didChangeRowOrderToOriginalOrder:(BOOL)isOriginalOrder;
- (void) csvDocumentDidChangeColumnNames:(CSVDocument *)document;
- (void) csvDocumentDidChangeNumColumns:(CSVDocument *)document;


@end
