//
//  DataTableHeaderView.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 14.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DataTableHeaderView.h"
#import "DataTableView.h"
#import "DataTableColumn.h"


@implementation DataTableHeaderView


- (void) mouseDown:(NSEvent *)theEvent
{
	NSPoint localPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSInteger colIndex = [self columnAtPoint:localPoint];
	
	// ask the column whether it wants to handle the click
	DataTableView *myTable = (DataTableView *)[self tableView];
	NSArray *allColumns = [myTable tableColumns];
	
	if ([allColumns count] > colIndex) {
		DataTableColumn *column = [allColumns objectAtIndex:colIndex];
		NSRect columnRect = [self headerRectOfColumn:colIndex];
		
		if (NSCellHitTrackableArea & [[column headerCell] hitTestForEvent:theEvent inRect:columnRect ofView:self]) {
			[[column headerCell] trackMouse:theEvent inRect:columnRect ofView:self untilMouseUp:NO];
			return;
		}
	}
	
	// not interested, let the header handle the click
	[super mouseDown:theEvent];
}


@end
