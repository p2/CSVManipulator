//
//  AppController.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 07.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "MyDocumentController.h"
#import "MyDocument.h"
#import "CSVDocument.h"
#import "CSVRowController.h"


@implementation AppController

@synthesize exportAccessoryView;
@synthesize exportHeadersCheckbox;
@synthesize exportFormatSelector;


- (void) dealloc
{
	self.exportAccessoryView = nil;
	self.exportHeadersCheckbox = nil;
	self.exportFormatSelector = nil;
	
	[super dealloc];
}
#pragma mark -



# pragma mark Clipboard
- (IBAction) newDocumentFromClipboard:(id)sender
{
	NSString *pboardData = [[NSPasteboard generalPasteboard] stringForType:NSStringPboardType];
	if (pboardData) {
		NSDocumentController *docController = [NSDocumentController sharedDocumentController];
		MyDocument *myDocument = [docController currentDocument];
		
		// create a new document if current document is not empty (or if there is none)
		NSError *error;
		if (!myDocument || [[myDocument.csvDocument numRows] intValue] > 0) {
			myDocument = [docController openUntitledDocumentAndDisplay:YES error:&error];
			
			// Failed to open a new document
			if (!myDocument) {
				[docController presentError:error];
			}
		}
		
		// parse string
		[myDocument.csvDocument parseCSVString:pboardData error:nil];
		myDocument.documentEdited = YES;
	}
	else {
		NSLog(@"No data is available from the clipboard");
	}
}
#pragma mark -



#pragma mark Saving
- (IBAction) exportDocument:(id)sender
{
	// get active document
//	NSDocumentController *docController = [NSDocumentController sharedDocumentController];
//	MyDocument *myDocument = [docController currentDocument];
	
	// configure the panel
	NSSavePanel *exportPanel = [NSSavePanel savePanel];
	[exportPanel setDelegate:self];
	[exportPanel setAccessoryView:exportAccessoryView];
	
	// TODO: Adjust the selected format
	
	NSInteger result = [exportPanel runModal];
	
	// got the OK -> handle export
	if (result == NSFileHandlingPanelOKButton) {
		
	}
}


@end
