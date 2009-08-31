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

@implementation DataTableView



#pragma mark Tasks

// override this to display placeholders at empty cells
- (void) drawRow:(NSInteger)rowIndex clipRect:(NSRect)clipRect
{
	if (![self isRowSelected:rowIndex]) {
		MyDocument *myDocument = [[self delegate] document];
		
		NSUInteger i = 0;
		for (NSTableColumn *column in [self tableColumns]) {
			NSRect cellRect = [self frameOfCellAtColumn:i row:rowIndex];
			
			// got data, call super implementation
			if([myDocument hasDataAtRow:rowIndex forColumnKey:[column identifier]]) {
				[super drawRow:rowIndex clipRect:cellRect];
			}
			
			// no data, draw a placeholder
			else {
				//[[self delegate] tableView:self willDisplayCell:XY forTableColumn:YZ row:rowIndex];
				[self lockFocus];
				NSColor *bgColor = [[NSColor controlAlternatingRowBackgroundColors] objectAtIndex:(rowIndex % 2)];
				[bgColor set];
				NSRectFill(cellRect);
				NSColor *fgColor = [NSColor lightGrayColor];
				[fgColor set];
				float circleRadius = 1.5;
				NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(
															(cellRect.origin.x + (cellRect.size.width / 2) - circleRadius),		// x
															(cellRect.origin.y + (cellRect.size.height / 2) - circleRadius),		// y
															 2 * circleRadius,														// width
															 2 * circleRadius														// height
																							 )];
				[circlePath fill];
				[self unlockFocus];
			}
			
			i++;
		}
	}
	else {
		[super drawRow:rowIndex clipRect:clipRect];
	}
}


// this controls sorting - overridden since we don't want the table to re-sort when we click the checkbox in the header, we...
- (void) setSortDescriptors:(NSArray *) array
{
	if(sortDescriptorsArray != array) {
		[sortDescriptorsArray release];
		sortDescriptorsArray = [array retain];
	}
}

// ...call the super implementation ourselves whenever necessary
- (void) reallySetSortDescriptors
{
	[super setSortDescriptors:sortDescriptorsArray];
}
#pragma mark -



#pragma mark Generic
- (void) dealloc
{
	[sortDescriptorsArray release];
	
	[super dealloc];
}


@end
