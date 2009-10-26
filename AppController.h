//
//  AppController.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 07.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
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
