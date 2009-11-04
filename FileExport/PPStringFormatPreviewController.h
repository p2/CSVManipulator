//
//  PPStringFormatPreviewController.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 11/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PPStringFormatPreviewController : NSWindowController {
	NSString *panelTitle;
	IBOutlet NSTextView *previewField;
}

@property (nonatomic, copy) NSString *panelTitle;
@property (nonatomic, retain) IBOutlet NSTextView *previewField;


- (void) previewString:(NSString *)string;


@end
