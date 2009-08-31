//
//  CSVWindowController.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 06.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CSVWindowController.h"
#import "MyDocument.h"
#import "PPStringFormat.h"
#import "CSVDocument.h"
#import "CSVColumn.h"
#import "DataTableView.h"
#import "DataTableColumn.h"
#import "DataTableHeaderCell.h"
#import "PPToolbarView.h"

#define COLUMN_MIN_WIDTH 40


@implementation CSVWindowController

@synthesize document;
@synthesize mainTable;
@synthesize mainToolbar;

@synthesize exportAccessoryView;


- (void) dealloc
{
	self.document = nil;
	
	self.mainTable = nil;
	self.mainToolbar = nil;
	
	self.exportAccessoryView = nil;
	
	[super dealloc];
}

- (void) awakeFromNib
{
	NSNumber *top_border_width = [NSNumber numberWithInt:1];
	mainToolbar.borderWidths = [NSArray arrayWithObjects:top_border_width, [NSNull null], [NSNull null], [NSNull null], nil];
	
	// document is still loading
	if (!document.documentLoaded) {
		[self performSelector:@selector(showProgressSheet) withObject:nil afterDelay:0.01];
		//[self showProgressSheet];			// does somehow not work so shortly after awakeFromNib
	}
	
	// document did already load all data
	else {
		[self redefineTable];
	}
	
	
}

- (void) windowWillClose:(NSNotification *)notification
{
	//[document setLastChoiceFormat:[self outputFormat]];
}
#pragma mark -



#pragma mark Export
- (IBAction) exportDocument:(id)sender
{
	NSSavePanel *exportPanel = [NSSavePanel savePanel];
	
	// configure the panel
	[exportPanel setDelegate:self];
	[exportPanel setAccessoryView:exportAccessoryView];
	
	NSInteger result = [exportPanel runModal];
	
	// got the OK, handle export
	if (result == NSFileHandlingPanelOKButton) {
		
	}
}

// TODO: needed?
- (NSInteger) outputFormat
{
	NSMenuItem *selectedItem = [copyAsKindPopup selectedItem];
	if(selectedItem) {
		return [selectedItem tag];
	}
	return 0;
}
#pragma mark -



#pragma mark Data Control
- (void) addToCSVRow:(id)sender
{
	[document addToCSVRow:sender];
}
- (void) removeFromCSVRow:(id)sender
{
	[document removeFromCSVRow:sender];
}

- (IBAction) restoreOriginalOrder:(id)sender;
{
	[document restoreOriginalOrder];
}

- (void) didRestoreOriginalOrder
{
	[mainTable setSortDescriptors:nil];
	[mainTable reallySetSortDescriptors];		// necessary since we have overridden setSortDescriptors:
}
#pragma mark -



#pragma mark TableView Delegate
- (void) redefineTable
{
	// remove OLD columns
	for (NSTableColumn *oldColumn in [mainTable tableColumns]) {
		[[oldColumn headerCell] unbind:@"stringValue"];
		[[oldColumn headerCell] unbind:@"checked"];
		[oldColumn unbind:@"value"];
		[mainTable removeTableColumn:oldColumn];
	}
	
	// clean popups
//	[calculationSourcePopup removeAllItems];
//	[calculationTargetPopup removeAllItems];
	
	// new headers, new bindings
	NSInteger numHeaders = [document numColumns];
	if (numHeaders > 0) {
		NSRect mainTableBounds = [mainTable frame];
		int columnWidth = ceilf(mainTableBounds.size.width / numHeaders);
		columnWidth = (columnWidth < COLUMN_MIN_WIDTH) ? COLUMN_MIN_WIDTH : columnWidth;
		
		// loop columns to add them
		for (CSVColumn *column in [document columns]) {
			
			// compose the column and add it to the table
			DataTableColumn *tableColumn = [[DataTableColumn alloc] init];
			[tableColumn setIdentifier:column.key];
			[tableColumn setWidth:columnWidth];
			[tableColumn setMinWidth:COLUMN_MIN_WIDTH];
			[[tableColumn headerCell] setEditable:YES];
			
			[mainTable addTableColumn:tableColumn];
			
			// update popups
//			[calculationSourcePopup addItemWithTitle:[NSString stringWithFormat:@"%@ (%@)", column.name, column.key]];
//			[calculationTargetPopup addItemWithTitle:[NSString stringWithFormat:@"%@ (%@)", column.name, column.key]];
		}
		
		// loop columns again to bind them - must be done after adding to prevent a "was mutated while being enumerated" error
		for (DataTableColumn *tableColumn in [mainTable tableColumns]) {
			NSString *key = [tableColumn identifier];
			
			[tableColumn bind:@"value"
					 toObject:document.csvDocument.rowController
				  withKeyPath:[NSString stringWithFormat:@"arrangedObjects.rowValues.%@", key]
					  options:nil];
			
			// also bind column header
			[[tableColumn headerCell] bind:@"stringValue"
								  toObject:document.csvDocument.columnDict
							   withKeyPath:[NSString stringWithFormat:@"%@.name", key]
								   options:nil];
			[[tableColumn headerCell] bind:@"checked"
								  toObject:document.csvDocument.columnDict
							   withKeyPath:[NSString stringWithFormat:@"%@.active", key]
								   options:nil];
		}
	}
	
	[mainTable setNeedsDisplay:YES];			// !! does not remove redundant column (graphical glitch)
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification
{
	NSInteger selected_row = [mainTable selectedRow];
	if (selected_row >= 0) {
		
		// if an empty row was selected, jump into edit mode of the first field
		if (![document hasAnyDataAtRow:selected_row]) {
			[mainTable editColumn:0 row:selected_row withEvent:nil select:YES];
		}
	}
}

- (void) tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
	if (mainTable == tableView) {
		NSEvent *current = [[NSApplication sharedApplication] currentEvent];
		NSPoint windowLocation = [current locationInWindow];
		NSPoint viewLocation = [tableView convertPoint:windowLocation fromView:nil];
		
		NSArray *columns = [tableView tableColumns];
		NSUInteger index = [columns indexOfObject:tableColumn];
		NSRect columnRect = [tableView rectOfColumn:index];
		
		// hit the checkbox
		if ((viewLocation.x - columnRect.origin.x) < 20.0) {
			DataTableHeaderCell *cell = (DataTableHeaderCell *)[tableColumn headerCell];
			
			cell.checked = !cell.isChecked;
			[document.csvDocument setHeaderActive:[cell isChecked] forColumnKey:[tableColumn identifier]];
			[tableView setNeedsDisplay:YES];
		}
		
		// hit the column header title
		else {
			[(DataTableView *)tableView reallySetSortDescriptors];
			[document setDataIsAtOriginalOrder:NO];
		}
	}
}

- (void) tableView:(NSTableView *)tableView didDragTableColumn:(NSTableColumn *)tableColumn
{
	if(mainTable == tableView) {
		NSEnumerator *walker = [[tableView tableColumns] objectEnumerator];
		NSMutableArray *arr = [NSMutableArray array];
		id col;
		
		while(col = [walker nextObject]) {
			[arr addObject:[col identifier]];
		}
		
		//[document setColumnOrder:arr];
		document.documentEdited = YES;
	}
}

- (void) refreshData
{
	[mainTable reloadData];
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
		[progressIndicator setDoubleValue:(double)percentage];
		[progressPercentage setFloatValue:(100 * percentage)];
	}
}

- (void) hideProgressSheet
{
	if ([progressSheet isVisible]) {
		[self updateProgressSheetProgress:1.0];
		
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


@end
