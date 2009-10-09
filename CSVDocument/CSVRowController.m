//
//  CSVRowController.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 22.02.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#ifndef IPHONE
#import "CSVRowController.h"
#import "CSVRow.h"
#import "CSVDocument.h"


@implementation CSVRowController

@synthesize document;

- (id) newObject
{
	return [[CSVRow rowForDocument:document] retain];
}

- (void) add:(id)sender
{
	[document setNumRowsWithInt:[[self content] count] + 1];		// that +1 compensates for the deferred inserting NSArrayController does
	[super add:sender];
}

- (void) remove:(id)sender
{
	[super remove:sender];
	[document setNumRowsWithInt:[[self content] count]];
}


@end
#endif
