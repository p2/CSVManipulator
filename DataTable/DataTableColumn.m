//
//  DataTableColumn.m
//  check
//
//  Created by Pascal Pfiffner on 04.03.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DataTableColumn.h"
#import "DataTableHeaderCell.h"
#import "CSVColumn.h"


@implementation DataTableColumn

@synthesize headerCell;


- (id) init
{
	self = [super init];
	if (nil != self) {
		self.headerCell = [[[DataTableHeaderCell alloc] init] autorelease];
		headerCell.checked = YES;
	}
	
	return self;
}

- (void) dealloc
{
	self.headerCell = nil;
	
	[super dealloc];
}
#pragma mark -


@end
