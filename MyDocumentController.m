//
//  MyDocumentController.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 30.08.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import "MyDocumentController.h"


@implementation MyDocumentController

@synthesize openPanelAccessoryView;
@synthesize openPanelFilename;


- (void) dealloc
{
	self.openPanelAccessoryView = nil;
	self.openPanelFilename = nil;
	
	[super dealloc];
}



#pragma mark - Open Panel
- (void)panelSelectionDidChange:(id)sender
{
	NSArray *curFiles = [sender filenames];
	
	if ([curFiles count] > 0) {
		NSString *firstName = [curFiles objectAtIndex:0];
		[openPanelFilename setStringValue:firstName];
	}
	
	/*
			NSDictionary *fAttrs = [[NSFileManager defaultManager] fileAttributesAtPath:curPath traverseLink:YES];
			if (fAttrs != nil) {
				[infoFile setStringValue: [curPath lastPathComponent]];
				[infoMod setStringValue: [[fAttrs objectForKey:NSFileModificationDate] descriptionWithCalendarFormat:@"%a, %b %d, %Y %H:%M:%S" timeZone:nil locale:nil]];
				[infoOwner setStringValue: [fAttrs objectForKey: NSFileOwnerAccountName]];
				[infoGroup setStringValue: [fAttrs objectForKey: NSFileGroupOwnerAccountName]];
			}
	*/
}

- (void)openDocument:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	// configure the panel
	[openPanel setDelegate:self];
	[openPanel setAccessoryView:openPanelAccessoryView];
	NSArray *fileTypes = nil;
	[openPanel setAllowsMultipleSelection:YES];
	
	// open all selected files
	NSInteger result = [openPanel runModalForDirectory:nil file:nil types:fileTypes];
	if (result == NSOKButton) {
		for (NSURL *filePath in [openPanel URLs]) {
			NSError *error;
			
			// file could not be opened
			if (nil == [self openDocumentWithContentsOfURL:filePath display:YES error:&error]) {
				[self presentError:error];
			}
		}
	}
}


@end
