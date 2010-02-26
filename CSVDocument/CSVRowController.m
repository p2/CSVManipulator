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
@dynamic headerSortDescriptor;


- (id) initWithContent:(id)content
{
	self = [super initWithContent:content];
	if (self) {
		[self setSortDescriptors:nil];
	}
	return self;
}

- (void) dealloc
{
	self.headerSortDescriptor = nil;
	
	[super dealloc];
}
#pragma mark -



#pragma mark KVC
- (NSSortDescriptor *) headerSortDescriptor
{
	if (nil == headerSortDescriptor) {
		self.headerSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"headerRowPosition" ascending:YES] autorelease];
	}
	return headerSortDescriptor;
}
- (void) setHeaderSortDescriptor:(NSSortDescriptor *)newDescriptor
{
	if (newDescriptor != headerSortDescriptor) {
		[headerSortDescriptor release];
		headerSortDescriptor = [newDescriptor retain];
	}
}
#pragma mark -



#pragma mark Sorting
- (void) setSortDescriptors:(NSArray *)newSortDescriptors
{
	NSMutableArray *newDesc = [NSMutableArray arrayWithObject:self.headerSortDescriptor];		// keeps the header rows on top
	if (nil != newSortDescriptors) {
		[newDesc addObjectsFromArray:newSortDescriptors];
	}
	[super setSortDescriptors:[[newDesc copy] autorelease]];
}
#pragma mark -



#pragma mark Objects
- (id) newObject
{
	return [[CSVRow rowForDocument:document] retain];
}

- (void) add:(id)sender
{
	[document setNumRowsWithInt:[[self content] count] + 1];		// that +1 compensates for the deferred inserting NSArrayController does
	[super add:sender];
}

- (void) addObject:(id)object
{
	NSUndoManager *undoManager = [[document document] undoManager];
	[undoManager registerUndoWithTarget:self selector:@selector(removeObject:) object:object];
	//[undoManager setActionName:NSLocalizedString(@"Add Row", nil)];
	
	[super addObject:object];
}

- (void) remove:(id)sender
{
	[super remove:sender];
	[document setNumRowsWithInt:[[self content] count]];
}

- (void) removeObject:(id)object
{
	NSUndoManager *undoManager = [[document document] undoManager];
	[undoManager registerUndoWithTarget:self selector:@selector(addObject:) object:object];
	//[undoManager setActionName:NSLocalizedString(@"Remove Row", nil)];
	
	[super removeObject:object];
}


@end
#endif
