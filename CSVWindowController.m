//
//  CSVWindowController.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 06.01.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import "CSVWindowController.h"
#import "MyDocument.h"
#import "PPStringFormat.h"
#import "PPStringFormatManager.h"
#import "CSVDocument.h"
#import "CSVColumn.h"
#import "CSVInspector.h"
#import "DataTableColumn.h"
#import "DataTableHeaderCell.h"
#import "DataTableCell.h"
#import "PPToolbarView.h"

#define COLUMN_MIN_WIDTH 40
#define kHeaderColumnIdentifier @"_theHeaderRowColumn"


@interface CSVWindowController ()

- (void) addColumnWithKey:(NSString *)columnKey atPosition:(NSUInteger)position;
- (void) removeColumn:(NSTableColumn *)tableColumn;
- (void) moveColumn:(NSInteger)oldPosition ofTable:(NSTableView *)aTableView to:(NSInteger)newPosition;
- (void) didMoveColumn:(NSInteger)oldPosition ofTable:(NSTableView *)aTableView to:(NSInteger)newPosition;

@end


@implementation CSVWindowController

@synthesize document;
@synthesize mainTable;
@synthesize mainToolbar;
@synthesize progressSheet;

@synthesize addRowItem;
@synthesize removeRowItem;
@synthesize addColumnItem;
@synthesize removeColumnItem;
@synthesize restoreOrderItem;
@synthesize showFormatsItem;


- (void) dealloc
{
	self.document = nil;
	
	self.mainTable = nil;
	self.mainToolbar = nil;
	
	self.progressSheet = nil;
	
	self.addRowItem = nil;

	self.addRowItem = nil;
	self.removeRowItem = nil;
	self.addColumnItem = nil;
	self.removeColumnItem = nil;
	self.restoreOrderItem = nil;
	self.showFormatsItem = nil;

	[super dealloc];
}

- (void) awakeFromNib
{
	mainToolbar.borderWidth = PPBorderWidthMake(1.f, 0.f, 0.f, 0.f);
	
	// the following enables prevention of moving a column before the first column
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tableViewColumnDidMove:)
												 name:NSTableViewColumnDidMoveNotification
											   object:mainTable];
	
	// document is still loading
	if (!document.documentLoaded) {
		[self performSelector:@selector(showProgressSheet) withObject:nil afterDelay:0.01f];
	}
	
	// document did already load all data
	else {
		[self redefineTable];
	}
}
/*
- (void) windowWillClose:(NSNotification *)notification
{
}	//*/
#pragma mark -



#pragma mark Data Control
- (IBAction) addNewColumn:(id)sender
{
	[self addColumnWithKey:[document.csvDocument nextAvailableColumnKey] atPosition:UINT_MAX];
	// TODO: Tell the CSVInspector when we do crazy stuff like this
}

- (void) addColumnWithKey:(NSString *)columnKey atPosition:(NSUInteger)position
{
	CSVColumn *newColumn = [CSVColumn columnWithKey:columnKey];
	if ([document.csvDocument addColumn:newColumn]) {
		[self addColumn:newColumn toTable:mainTable atPosition:position withWidth:0.f];
		
		// allow undo
		NSUndoManager *undoManager = [document undoManager];
		[undoManager registerUndoWithTarget:self selector:@selector(removeColumnWithIdentifier:) object:columnKey];
		[undoManager setActionName:NSLocalizedString([undoManager isUndoing] ? @"Remove Column" : @"Add Column", nil)];
	}
}


- (IBAction) removeSelectedColumns:(id)sender
{
	NSIndexSet *indexes = [mainTable selectedColumnIndexes];
	if ([indexes count] > 0) {
		NSArray *exColumns = [[mainTable tableColumns] objectsAtIndexes:indexes];
		
		for (NSTableColumn *tableColumn in exColumns) {
			[self removeColumn:tableColumn];
		}
	}
}

- (void) removeColumnWithIdentifier:(NSString *)columnIdentifier
{
	for (NSTableColumn *tableColumn in [mainTable tableColumns]) {
		if ([[tableColumn identifier] isEqualToString:columnIdentifier]) {
			[self removeColumn:tableColumn];
			return;
		}
	}
	NSLog(@"Can't remove column with identifier '%@'", columnIdentifier);
}

- (void) removeColumn:(NSTableColumn *)tableColumn
{
	NSUndoManager *undoManager = [document undoManager];
	
	id columnIdentifier = [tableColumn identifier];
	NSUInteger columnIndex = [mainTable columnWithIdentifier:columnIdentifier];
	
	[[undoManager prepareWithInvocationTarget:self] addColumnWithKey:columnIdentifier atPosition:columnIndex];
	[undoManager setActionName:NSLocalizedString([undoManager isUndoing] ? @"Add Column" : @"Remove Column", nil)];
	
	// remove
	CSVColumn *csvColumn = [document.csvDocument columnWithKey:columnIdentifier];
	if ([document.csvDocument removeColumn:csvColumn]) {
		[mainTable removeTableColumn:tableColumn];
		[mainTable sizeLastColumnToFit];
	}
	else {
		NSLog(@"Can't remove column %@ as it is not a valid column", columnIdentifier);
	}
}

- (void) moveColumn:(NSInteger)oldPosition ofTable:(NSTableView *)aTableView to:(NSInteger)newPosition
{
	if (oldPosition != newPosition) {
		[mainTable moveColumn:oldPosition toColumn:newPosition];
		[self didMoveColumn:oldPosition ofTable:aTableView to:newPosition];
	}
}

- (void) didMoveColumn:(NSInteger)oldPosition ofTable:(NSTableView *)aTableView to:(NSInteger)newPosition
{
	if (oldPosition != newPosition) {
		NSUndoManager *undoManager = [document undoManager];
		[[undoManager prepareWithInvocationTarget:self] moveColumn:newPosition ofTable:aTableView to:oldPosition];
		[undoManager setActionName:NSLocalizedString(@"Column Order", nil)];
		
		// collect column keys
		NSArray *allColumns = [aTableView tableColumns];
		NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[allColumns count]];
		for (DataTableColumn *col in allColumns) {
			if (![kHeaderColumnIdentifier isEqualToString:[col identifier]]) {
				[arr addObject:[col identifier]];
			}
		}
		
		// propagate changes to CSVDocument
		[document.csvDocument setColumnOrderByKeys:arr];
		document.documentEdited = YES;
	}
}

			
- (IBAction) addCSVRow:(id)sender
{
	[document.csvDocument.rowController add:sender];
	document.documentEdited = YES;
}

- (IBAction) removeCSVRow:(id)sender
{
	[document.csvDocument.rowController remove:sender];
	document.documentEdited = YES;
}

- (void) removeSelectedRows:(id)sender
{
	NSIndexSet *indexes = [mainTable selectedRowIndexes];
	if ([indexes count] > 0) {
		NSArray *exRows = [document.csvDocument.rows objectsAtIndexes:indexes];
		
		for (CSVRow *row in exRows) {
			[document.csvDocument removeRow:row];
		}
	}
}

- (IBAction) restoreOriginalOrder:(id)sender;
{
	[document restoreOriginalOrder];
}

- (void) didRestoreOriginalOrder
{
	[mainTable setSortDescriptors:nil];
	[mainTable setSortDescriptorsWithColumn:nil];		// necessary since we have overridden setSortDescriptors:
	[[mainTable headerView] setNeedsDisplay:YES];
}
#pragma mark -



#pragma mark TableView Delegate
- (void) redefineTable
{
	// remove OLD columns
	NSArray *columnsToRemove = [[mainTable tableColumns] copy];
	for (NSTableColumn *oldColumn in columnsToRemove) {
		[oldColumn unbind:@"headerTitle"];
		[oldColumn unbind:@"value"];
		[mainTable removeTableColumn:oldColumn];
	}
	[columnsToRemove release];
	
	// first column is a checkbox column to specify header cells
	CGFloat firstColumnWidth = 30.0;
	NSButtonCell *firstDataCell = [[[NSButtonCell alloc] init] autorelease];
	[firstDataCell setButtonType:NSSwitchButton];
	[firstDataCell setControlSize:NSSmallControlSize];
	[firstDataCell setTitle:@""];
	
	DataTableColumn *firstTableColumn = [DataTableColumn column];
	[firstTableColumn setIdentifier:kHeaderColumnIdentifier];
	[firstTableColumn setDataCell:firstDataCell];
	[firstTableColumn setWidth:firstColumnWidth];
	firstTableColumn.resizingMask = NSTableColumnNoResizing;
	[[firstTableColumn headerCell] setTitle:@"⚑"];
	[[firstTableColumn headerCell] setAlignment:NSCenterTextAlignment];
	[[firstTableColumn headerCell] setShowsCheckbox:NO];
	
	[mainTable addTableColumn:firstTableColumn];
	
	// bind checkbox values
	[firstTableColumn bind:@"value"
				  toObject:document.csvDocument.rowController
			   withKeyPath:@"arrangedObjects.isHeaderRow"
				   options:nil];
	
	// new headers, new bindings
	NSInteger numColumns = [document numColumns];
	if (numColumns > 0) {
		NSRect mainTableBounds = [mainTable frame];
		int columnWidth = ceilf((mainTableBounds.size.width - firstColumnWidth) / numColumns);
		columnWidth = (columnWidth < COLUMN_MIN_WIDTH) ? COLUMN_MIN_WIDTH : columnWidth;
		
		// loop columns to add the table columns
		for (CSVColumn *column in [document columns]) {
			[self addColumn:column toTable:mainTable atPosition:UINT_MAX withWidth:columnWidth];
		}
		
		[mainTable sizeLastColumnToFit];
	}
}

- (void) addColumn:(CSVColumn *)newColumn toTable:(NSTableView *)aTableView atPosition:(NSUInteger)position withWidth:(CGFloat)width
{
	if (aTableView == mainTable) {
		
		// create the table column
		DataTableColumn *tableColumn = [DataTableColumn column];
		[tableColumn setIdentifier:newColumn.key];
		[tableColumn setDataCell:[DataTableCell cell]];
		[tableColumn setMinWidth:COLUMN_MIN_WIDTH];
		if (width > COLUMN_MIN_WIDTH) {
			[tableColumn setWidth:width];
		}
		[[tableColumn headerCell] setEditable:YES];
		[[tableColumn headerCell] setChecked:newColumn.active];
		
		// bind the column row values
		[tableColumn bind:@"value"
				 toObject:document.csvDocument.rowController
			  withKeyPath:[NSString stringWithFormat:@"arrangedObjects.rowValues.%@", newColumn.key]
				  options:nil];
		
		//	[tableColumn bind:@"active"
		//			 toObject:document.csvDocument.columnDict
		//		  withKeyPath:[NSString stringWithFormat:@"%@.active", key]
		//			  options:nil];					// does somehow not work. Using the delegate method for now
		
		// also bind column header
		[tableColumn bind:@"headerTitle"
				 toObject:document.csvDocument.columnDict
			  withKeyPath:[NSString stringWithFormat:@"%@.type", newColumn.key]
				  options:nil];
			
		// add the column
		[mainTable addTableColumn:tableColumn];
		NSUInteger lastColumnIndex = [[mainTable tableColumns] count] - 1;
		if (position < lastColumnIndex) {
			[mainTable moveColumn:lastColumnIndex toColumn:position];
		}
	}
}


- (void) tableViewSelectionDidChange:(NSNotification *)notification
{
	NSInteger selected_row = [mainTable selectedRow];
	if (selected_row >= 0) {
		
		// if an empty row was selected, jump into edit mode of the first field
		if (![document hasAnyDataAtRow:selected_row]) {
			[mainTable editColumn:1 row:selected_row withEvent:nil select:YES];
		}
	}
}


- (void) tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
	// set sort descriptors
	if (mainTable == tableView) {
		[(DataTableView *)tableView setSortDescriptorsWithColumn:(DataTableColumn *)tableColumn];
		[document setDataIsAtOriginalOrder:NO];
	}
}


- (void) tableView:(DataTableView *)tableView didChangeTableColumnState:(DataTableColumn *)tableColumn
{
	[document.csvDocument setColumnActive:tableColumn.active forColumnKey:[tableColumn identifier]];
	document.documentEdited = YES;
}


- (void) tableView:(NSTableView*)aTableView mouseDownInHeaderOfTableColumn:(NSTableColumn*)tableColumn
{
	if (0 == [[aTableView tableColumns] indexOfObject:tableColumn]) {
		[aTableView setAllowsColumnReordering:NO];
	}
	else {
		[aTableView setAllowsColumnReordering:YES];
	}
}

- (void) tableView:(NSTableView *)tableView didDragTableColumn:(NSTableColumn *)tableColumn
{
	if (mainTable == tableView) {
		if (![kHeaderColumnIdentifier isEqualToString:[tableColumn identifier]]) {
			NSInteger newPos = [[tableView tableColumns] indexOfObject:tableColumn];
			
			// a move only happened when newPos is >= 0
			if (newPos >= 0) {
				
				// determine old position for the undo operation
				NSInteger oldPos = 0;
				for (CSVColumn *column in document.csvDocument.columns) {
					if ([column.key isEqualToString:[tableColumn identifier]]) {
						break;
					}
					oldPos++;
				}
				oldPos++;			// compensating for the first column, which is not a column of csvDocument
				
				[self didMoveColumn:oldPos ofTable:mainTable to:newPos];
			}
		}
	}
}

- (void) tableViewColumnDidMove:(NSNotification*)aNotification
{
	NSDictionary* userInfo = [aNotification userInfo];
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	
	// temporarily stop listening to column moves to prevent recursion
	[center removeObserver:self name:NSTableViewColumnDidMoveNotification object:nil];
	
	// if the user tries to move the first column out, move it back (should not be possible since we disable moving the first column)
	if (0 == [[userInfo objectForKey:@"NSOldColumn"] intValue]) {
		[mainTable moveColumn:[[userInfo objectForKey:@"NSNewColumn"] intValue] toColumn:0];
	}
	
	// if the user tries to move a column in front of the first column, move it back
	else if (0 == [[userInfo objectForKey:@"NSNewColumn"] intValue]) {
		[mainTable moveColumn:0 toColumn:[[userInfo objectForKey:@"NSOldColumn"] intValue]];
	}
	
	// listen again for column moves
	[center addObserver:self selector:@selector(tableViewColumnDidMove:) name:NSTableViewColumnDidMoveNotification object:mainTable];
}
#pragma mark -



#pragma mark TableView DataSource
- (NSInteger) numberOfRowsInTableView:(NSTableView*)aTableView
{
	return 0;			// will not be used since we use bindings, but must be implemented to avoid warnings
}

- (id) tableView:(NSTableView*)aTableView objectValueForTableColumn:(NSTableColumn*)aTableColumn row:(int)rowIndex
{
	return nil;			// will not be used since we use bindings, but must be implemented to avoid warnings
}

- (void) tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
	NSArray *currentDescriptors = [aTableView sortDescriptors];
	document.dataIsAtOriginalOrder = (nil == currentDescriptors || 0 == [currentDescriptors count]);
}

- (void) refreshData
{
	[mainTable reloadData];
}
#pragma mark -



#pragma mark Toolbar
- (BOOL) validateToolbarItem:(NSToolbarItem *)theItem
{
	if (addRowItem == theItem) {
		return [document.csvDocument.rowController canInsert];
	}
	if (removeRowItem == theItem) {
		return [document.csvDocument.rowController canRemove];
	}
	if (addColumnItem == theItem) {
		return YES;
	}
	if (removeColumnItem == theItem) {
		return ([mainTable numberOfSelectedColumns] > 0);
	}
	if (showFormatsItem == theItem) {
		return YES;
	}
	if (restoreOrderItem == theItem) {
		return document.documentEdited;
	}
	return YES;
}
#pragma mark -



#pragma mark Inspector
- (IBAction) showInspector:(id)sender
{
	[CSVInspector show:sender];
}
#pragma mark -



#pragma mark Progress Sheet
- (void) showProgressSheet
{
	if (!document.documentLoaded) {
		[NSApp beginSheet:progressSheet modalForWindow:[self window] modalDelegate:nil didEndSelector:NULL contextInfo:nil];
	}
}

- (void) updateProgressSheetProgress:(CGFloat)percentage
{
	if ([progressSheet isVisible]) {
		[progressIndicator setIndeterminate:NO];
		[progressIndicator setDoubleValue:(double)percentage];
		[progressPercentage setFloatValue:(100 * percentage)];
	}
}

- (void) setProgressSheetIndeterminate:(NSNumber *)flag
{
	if ([progressSheet isVisible]) {
		[progressIndicator setIndeterminate:[flag boolValue]];
		[progressIndicator startAnimation:nil];
	}
}

- (void) hideProgressSheet
{
	if ([progressSheet isVisible]) {
		[self updateProgressSheetProgress:1.0];
		[progressIndicator stopAnimation:nil];
		
		[progressSheet orderOut:nil];
		[NSApp endSheet:progressSheet];
	}
}

- (void) abortImport:(id)sender
{
	[document abortImport];
}

- (void) didAbortImport:(BOOL)flag
{
	[importAbortedField setHidden:!flag];
}
#pragma mark -



#pragma mark Export
- (IBAction) showExportFormats:(id)sender
{
	[PPStringFormatManager show:sender];
}
#pragma mark -



#pragma mark Notifications
- (void) windowDidBecomeMain:(NSNotification *)notification
{
	[document windowDidBecomeMain:notification];
}

- (void) windowDidResignMain:(NSNotification *)notification
{
	[document windowDidResignMain:notification];
}

- (void) windowWillClose:(NSNotification *)notification
{
	[document windowDidResignMain:notification];
}


@end
