//
//  CSVRowController.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 22.02.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#ifndef IPHONE
#import <Cocoa/Cocoa.h>

@class CSVDocument;


@interface CSVRowController : NSArrayController {
	CSVDocument *document;
	NSSortDescriptor *headerSortDescriptor;
}

@property (nonatomic, assign) CSVDocument *document;
@property (nonatomic, retain) NSSortDescriptor *headerSortDescriptor;


@end
#endif
