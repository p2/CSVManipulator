//
//  GraphDocument.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 27.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GraphDocument.h"
#import "GraphWindowController.h"


@implementation GraphDocument

@synthesize mainWindowController;



- (void) dealloc
{
	self.mainWindowController = nil;
	
	[super dealloc];
}
#pragma mark -



#pragma mark Data
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    return YES;
}
#pragma mark -



#pragma mark Document Based Musts
- (NSString *) windowNibName {
    return @"GraphDocument";
}

- (void) makeWindowControllers
{
	self.mainWindowController = [[[GraphWindowController alloc] initWithWindowNibName:[self windowNibName]] autorelease];
	[self addWindowController:mainWindowController];
}


@end
