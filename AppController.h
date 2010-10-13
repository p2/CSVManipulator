//
//  AppController.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 07.01.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject {
	IBOutlet NSView *exportAccessoryView;
	IBOutlet NSButton *exportHeadersCheckbox;
	IBOutlet NSPopUpButton *exportFormatSelector;
}

@property (nonatomic, retain) IBOutlet NSView *exportAccessoryView;
@property (nonatomic, retain) IBOutlet NSButton *exportHeadersCheckbox;
@property (nonatomic, retain) IBOutlet NSPopUpButton *exportFormatSelector;

// clipboard
- (IBAction) newDocumentFromClipboard:(id)sender;

// saving
- (IBAction) exportDocument:(id)sender;


@end
