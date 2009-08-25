//
//  CSVRowController.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 22.02.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class CSVDocument;


@interface CSVRowController : NSArrayController {
	CSVDocument *document;
}

@property (nonatomic, assign) CSVDocument *document;


@end
