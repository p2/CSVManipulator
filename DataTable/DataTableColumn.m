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

- (id) init
{	
	self = [super init];
	if (nil != self) {
		[self setHeaderCell:[[[DataTableHeaderCell alloc] init] autorelease]];
		[self headerCell].checked = YES;
	}
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}
#pragma mark -



#pragma mark KVC
- (DataTableHeaderCell *) headerCell
{
	return [super headerCell];
}
- (void) setHeaderCell:(DataTableHeaderCell *)newHeaderCell
{
	[super setHeaderCell:newHeaderCell];
}


@end
