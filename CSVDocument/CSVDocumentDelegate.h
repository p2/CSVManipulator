//
//  CSVDocumentDelegate.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 26.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
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

@end
