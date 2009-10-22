//
//  MyDocumentController.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 30.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MyDocumentController : NSDocumentController {
	IBOutlet NSView *openPanelAccessoryView;
	IBOutlet NSTextField *openPanelFilename;
}

@property (nonatomic, retain) IBOutlet NSView *openPanelAccessoryView;
@property (nonatomic, retain) IBOutlet NSTextField *openPanelFilename;


@end
