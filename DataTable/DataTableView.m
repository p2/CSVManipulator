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
#import "DataTableHeaderCell.h"

@implementation DataTableView



#pragma mark Tasks

// this controls sorting - overridden since we don't want the table to re-sort when we click the checkbox in the header, we...
- (void) setSortDescriptors:(NSArray *) array
{
	if(sortDescriptorsArray != array) {
		[sortDescriptorsArray release];
		sortDescriptorsArray = [array retain];
	}
}

// ...call the super implementation ourselves whenever necessary
- (void) reallySetSortDescriptorsWithColumn:(DataTableColumn *)tableColumn
{
	[super setSortDescriptors:sortDescriptorsArray];
	
	// TODO: don't sort headerRows, keep them in the same order
	
	// make the header cell indicate sort status
	BOOL ascending = [[sortDescriptorsArray objectAtIndex:0] ascending];
	for (DataTableColumn *column in [self tableColumns]) {
		NSUInteger priority = (column == tableColumn) ? 0 : 1;
		[column.headerCell setSortAscending:ascending priority:priority];
	}
}
#pragma mark -



#pragma mark Generic
- (void) dealloc
{
	[sortDescriptorsArray release];
	
	[super dealloc];
}


@end
