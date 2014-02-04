//
//  PPStringFormatPreviewController.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 11/4/09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
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
