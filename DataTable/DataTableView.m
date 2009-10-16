//
//  DataTableView.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 22.02.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DataTableView.h"
#import "DataTableViewDelegate.h"
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



#pragma mark Awakening
- (void) awakeFromNib
{
	// exchange the header view
	if (nil != [self headerView]) {
		NSRect frame = [[self headerView] frame];
		DataTableHeaderView *newHeader = [[[DataTableHeaderView alloc] initWithFrame:frame] autorelease];
		[self setHeaderView:newHeader];
	}
}
# pragma mark -



#pragma mark Column Delegate


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
		ascending = column.sortAscending;
		if (column == tableColumn) {
			[column setSortAscending:!ascending priority:0];
		}
		else {
			[column setSortAscending:ascending priority:1];
		}
	}
}

- (void) columnDidChangeCheckedStatus:(DataTableColumn *)tableColumn
{
	if (nil != tableColumn) {
		if (self.delegate && [self.delegate respondsToSelector:@selector(tableView:didChangeTableColumnState:)]) {
			[self.delegate tableView:self didChangeTableColumnState:tableColumn];
		}
	}
}
#pragma mark -


@end
