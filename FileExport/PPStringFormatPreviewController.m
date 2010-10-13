//
//  PPStringFormatPreviewController.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 11/4/09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import "PPStringFormatPreviewController.h"


@implementation PPStringFormatPreviewController

@dynamic panelTitle;
@synthesize previewField;


- (void) dealloc
{
	self.previewField = nil;
	self.panelTitle = nil;

	[super dealloc];
}
#pragma mark -



#pragma mark KVC
- (NSString *) panelTitle
{
	return panelTitle;
}
- (void) setPanelTitle:(NSString *)newTitle
{
	if (newTitle != panelTitle) {
		[panelTitle release];
		panelTitle = [newTitle copyWithZone:[self zone]];
		
		if (nil != panelTitle) {
			[self.window setTitle:panelTitle];
		}
	}
}
#pragma mark -



#pragma mark Window Handling
- (void) windowDidLoad
{
	[previewField setFont:[NSFont fontWithName:@"Monaco" size:12.0]];
}

- (NSString *) windowFrameAutosaveName
{
	return @"PPStringFormatPrevievWindow";
}
#pragma mark -



#pragma mark Previewing
- (void) previewString:(NSString *)string
{
	[previewField setString:string];
}


@end
