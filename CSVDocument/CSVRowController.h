//
//  CSVRowController.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 22.02.08.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
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
