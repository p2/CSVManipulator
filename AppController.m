//
//  AppController.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 07.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "MyDocument.h"
#import "CSVDocument.h"
#import "CSVRowController.h"


@implementation AppController


# pragma mark READ from Clipboard
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


@end
