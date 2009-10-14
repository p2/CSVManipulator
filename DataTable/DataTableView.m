//
//  DataTableView.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 22.02.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DataTableView.h"
#import "MyDocument.h"
#import "DataTableColumn.h"
#import "DataTableHeaderView.h"
#import "DataTableHeaderCell.h"

@implementation DataTableView


#pragma mark Generic
- (void) dealloc
{
	[sortDescriptorsArray release];
	
	[super dealloc];
}
#pragma mark -



#pragma mark Tasks
- (void) awakeFromNib
{
	// exchange the header view
	if (nil != [self headerView]) {
		NSRect frame = [[self headerView] frame];
		DataTableHeaderView *newHeader = [[[DataTableHeaderView alloc] initWithFrame:frame] autorelease];
		[self setHeaderView:newHeader];
	}
}


// this controls sorting - overridden since we don't want the table to re-sort when we click the checkbox in the header, we...
- (void) setSortDescriptors:(NSArray *) array
{
	if (sortDescriptorsArray != array) {
		[sortDescriptorsArray release];
		sortDescriptorsArray = [array retain];
	}
}

// ...call the super implementation ourselves whenever necessary
- (void) setSortDescriptorsWithColumn:(DataTableColumn *)tableColumn
{
	[super setSortDescriptors:sortDescriptorsArray];
	
	// make the header cell indicate sort status
	BOOL ascending = NO;
	for (DataTableColumn *column in [self tableColumns]) {
		ascending = column.headerCell.sortAscending;
		if (column == tableColumn) {
			[column.headerCell setSortAscending:!ascending priority:0];
		}
		else {
			[column.headerCell setSortAscending:ascending priority:1];
		}
	}
}
#pragma mark -


@end
