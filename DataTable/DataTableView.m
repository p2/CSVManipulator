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

@interface DataTableView (Private)

- (void) ourWindowDidChangeKeyNotification:(NSNotification *)notification;

@end



@implementation DataTableView

@synthesize titleRowColumnIndex;


#pragma mark Generic
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[sortDescriptorsArray release];
	
	[super dealloc];
}
#pragma mark -



#pragma mark Awakening and Key Notifications
- (void) awakeFromNib
{
	// exchange the header view
	if (nil != [self headerView]) {
		NSRect frame = [[self headerView] frame];
		DataTableHeaderView *newHeader = [[[DataTableHeaderView alloc] initWithFrame:frame] autorelease];
		[self setHeaderView:newHeader];
	}
}

- (void) viewWillMoveToWindow:(NSWindow *)newWindow;
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
	[center addObserver:self selector:@selector(ourWindowDidChangeKeyNotification:) name:NSWindowDidResignKeyNotification object:newWindow];
	[center removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
	[center addObserver:self selector:@selector(ourWindowDidChangeKeyNotification:) name:NSWindowDidBecomeKeyNotification object:newWindow];
}

- (void) ourWindowDidChangeKeyNotification:(NSNotification *)notification
{
	[self setNeedsDisplay:YES];		// TODO: Maybe use setNeedsDisplayInRect: with the rects of the header rows?
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



#pragma mark TEST
- (void) keyDown:(NSEvent *)event
{
	unichar u = [[event charactersIgnoringModifiers] characterAtIndex:0];
	
	if (u == NSDeleteCharacter || u == NSDeleteFunctionKey) {
		[self interpretKeyEvents:[NSArray arrayWithObject:event]];
	}
	else {
		[super keyDown:event];
	}
}

- (void) deleteForward:(id)sender
{
	[self deleteBackward:sender];
}

- (void) deleteBackward:(id)sender
{
	id dataSource = [self dataSource];
	if ([dataSource respondsToSelector:@selector(removeSelectedRows:)]) {
		[dataSource performSelector:@selector(removeSelectedRows:) withObject:nil];
	}
}
#pragma mark -



#pragma mark Drawing
- (void) drawRow:(NSInteger)rowIndex clipRect:(NSRect)clipRect
{
	// draw background if we are a title row
	if (titleRowColumnIndex >= 0) {
		NSCell *titleRowCell = [self preparedCellAtColumn:titleRowColumnIndex row:rowIndex];
		if (1 == [titleRowCell intValue]) {
			[[self titleColorForRow:rowIndex] setFill];
			NSRectFill([self rectOfRow:rowIndex]);
		}
	}
	
	[super drawRow:rowIndex clipRect:clipRect];
}


- (NSColor *) titleColorForRow:(NSInteger)rowIndex
{
	CGFloat blendFraction = [[self window] isKeyWindow] ? 0.25 : 0.15;
	NSArray *colors = [NSColor controlAlternatingRowBackgroundColors];
	NSColor *myColor = [[colors objectAtIndex:rowIndex % [colors count]] blendedColorWithFraction:blendFraction ofColor:[NSColor blackColor]];
	
	return myColor;
}


@end
