//
//  GraphDocument.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 27.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class GraphWindowController;


@interface GraphDocument : NSDocument {
	GraphWindowController *mainWindowController;
}

@property (nonatomic, retain) GraphWindowController *mainWindowController;


@end
