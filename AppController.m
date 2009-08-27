//
//  AppController.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 07.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "MyDocument.h"
#import "GraphDocument.h"
#import "CSVDocument.h"
#import "CSVRowController.h"


@implementation AppController


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



#pragma mark Graphs
- (IBAction) newGraphWindow:(id)sender
{
	NSDocumentController *docController = [NSDocumentController sharedDocumentController];
	NSError *error = nil;
	
	// create the new document
	GraphDocument *newGraphDocument = [docController makeUntitledDocumentOfType:@"Graph" error:&error];
	if (nil != newGraphDocument) {
		[docController addDocument:newGraphDocument];
		[newGraphDocument makeWindowControllers];
		[newGraphDocument showWindows];
	}
	
	// got an error
	else {
		[docController presentError:error];
	}
}
#pragma mark -


@end
