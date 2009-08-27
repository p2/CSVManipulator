//
//  CSVDocumentDelegate.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 26.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class CSVDocument;


@protocol CSVDocumentDelegate <NSObject>

- (void) csvDocumentDidParseString:(CSVDocument *)doc;

@optional

- (void) csvDocumentDidParseNumRows:(NSUInteger)num_parsed;

@end
