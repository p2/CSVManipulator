//
//  MyDocumentController.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 30.08.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import <Cocoa/Cocoa.h>


@interface MyDocumentController : NSDocumentController <NSOpenSavePanelDelegate> {
	IBOutlet NSView *openPanelAccessoryView;
	IBOutlet NSTextField *openPanelFilename;
}

@property (nonatomic, retain) IBOutlet NSView *openPanelAccessoryView;
@property (nonatomic, retain) IBOutlet NSTextField *openPanelFilename;


@end
