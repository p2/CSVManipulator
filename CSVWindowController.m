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
#import "CSVInspector.h"
#import "DataTableView.h"
#import "DataTableColumn.h"
#import "DataTableHeaderCell.h"
#import "DataTableCell.h"
#import "PPToolbarView.h"

#define COLUMN_MIN_WIDTH 40


@implementation CSVWindowController

@synthesize document;
@synthesize mainTable;
@synthesize mainToolbar;

@synthesize progressSheet;
@synthesize exportSheet;


- (void) dealloc
{
	self.document = nil;
	
	self.mainTable = nil;
	self.mainToolbar = nil;
	
	self.progressSheet = nil;
	self.exportSheet = nil;
	
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
/*
- (void) windowWillClose:(NSNotification *)notification
{
}	//*/
#pragma mark -



#pragma mark Data Control
- (void) addCSVRow:(id)sender
{
	[document addCSVRow:sender];
}
- (void) removeCSVRow:(id)sender
{
	[document removeCSVRow:sender];
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
	for (NSTableColumn *oldColumn in [mainTable tableColumns]) {
		[oldColumn unbind:@"headerTitle"];
		[oldColumn unbind:@"value"];
		[mainTable removeTableColumn:oldColumn];
	}
	
	// first column is a checkbox column to specify header cells
	CGFloat firstColumnWidth = 30.0;
	NSButtonCell *firstDataCell = [[[NSButtonCell alloc] init] autorelease];
	[firstDataCell setButtonType:NSSwitchButton];
	[firstDataCell setControlSize:NSSmallControlSize];
	[firstDataCell setTitle:@""];
	
	DataTableColumn *firstTableColumn = [DataTableColumn column];
	[firstTableColumn setIdentifier:@"_theHeaderRowColumn"];
	[firstTableColumn setDataCell:firstDataCell];
	[firstTableColumn setWidth:firstColumnWidth];
	firstTableColumn.resizingMask = NSTableColumnNoResizing;
	[[firstTableColumn headerCell] setTitle:@"⚑"];
	[[firstTableColumn headerCell] setAlignment:NSCenterTextAlignment];
	[[firstTableColumn headerCell] setShowsCheckbox:NO];
	
	[mainTable addTableColumn:firstTableColumn];
	
	// new headers, new bindings
	NSInteger numHeaders = [document numColumns];
	if (numHeaders > 0) {
		DataTableCell *dataCell = [DataTableCell cell];
		NSRect mainTableBounds = [mainTable frame];
		int columnWidth = ceilf((mainTableBounds.size.width - firstColumnWidth) / numHeaders);
		columnWidth = (columnWidth < COLUMN_MIN_WIDTH) ? COLUMN_MIN_WIDTH : columnWidth;
		
		// loop columns to add the columns
		for (CSVColumn *column in [document columns]) {
			
			// compose the column and add it to the table
			DataTableColumn *tableColumn = [DataTableColumn column];
			[tableColumn setIdentifier:column.key];
			[tableColumn setDataCell:dataCell];
			[tableColumn setWidth:columnWidth];
			[tableColumn setMinWidth:COLUMN_MIN_WIDTH];
			[[tableColumn headerCell] setEditable:YES];
			
			[mainTable addTableColumn:tableColumn];
		}
		
		// loop columns again to bind them - must be done after adding to prevent a "was mutated while being enumerated" error
		for (DataTableColumn *tableColumn in [mainTable tableColumns]) {
			NSString *key = [tableColumn identifier];
			
			// first column with checkboxes
			if ([@"_theHeaderRowColumn" isEqualToString:key]) {
				[tableColumn bind:@"value"
						 toObject:document.csvDocument.rowController
					  withKeyPath:@"arrangedObjects.headerRow"
						  options:nil];
			}
			
			// data columns
			else {
				[tableColumn bind:@"value"
						 toObject:document.csvDocument.rowController
					  withKeyPath:[NSString stringWithFormat:@"arrangedObjects.rowValues.%@", key]
						  options:nil];
			//	[tableColumn bind:@"active"
			//			 toObject:document.csvDocument.columnDict
			//		  withKeyPath:[NSString stringWithFormat:@"%@.active", key]
			//			  options:nil];					// does somehow not work. Using the delegate method for now
				
				// also bind column header
				[tableColumn bind:@"headerTitle"
						 toObject:document.csvDocument.columnDict
					  withKeyPath:[NSString stringWithFormat:@"%@.type", key]
						  options:nil];
			}
		}
		
		[mainTable sizeLastColumnToFit];
	}
	
	[mainTable setNeedsDisplay:YES];			// !! does not remove redundant column (graphical glitch)
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
	[document.csvDocument setHeaderActive:tableColumn.active forColumnKey:[tableColumn identifier]];
	document.documentEdited = YES;
}


- (void) tableView:(NSTableView *)tableView didDragTableColumn:(NSTableColumn *)tableColumn
{
	if (mainTable == tableView) {
		NSMutableArray *arr = [NSMutableArray array];
		
		// propagate changes to CSVDocument
		for (DataTableColumn *col in [tableView tableColumns]) {
			CSVColumn *csvCol = [document.csvDocument.columnDict objectForKey:[col identifier]];
			if (nil != csvCol) {
				[arr addObject:csvCol];
			}
		}
		document.csvDocument.columns = [arr copy];
		document.documentEdited = YES;
	}
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
#pragma mark -



#pragma mark Export
- (IBAction) showExportSheet:(id)sender
{
	[NSApp beginSheet:exportSheet modalForWindow:[self window] modalDelegate:nil didEndSelector:NULL contextInfo:nil];
}

- (IBAction) exportDocument:(id)sender
{
	// end the sheet
	[self hideExportSheet:nil];
	
	// configure the panel
	NSSavePanel *exportPanel = [NSSavePanel savePanel];
	[exportPanel setDelegate:self];
	//[exportPanel setAccessoryView:exportAccessoryView];
	
	NSInteger result = [exportPanel runModal];
	
	// got the OK, handle export
	if (result == NSFileHandlingPanelOKButton) {
		
	}
}

- (IBAction) hideExportSheet:(id)sender
{
	if ([exportSheet isVisible]) {
		
		// dismiss
		[exportSheet orderOut:nil];
		[NSApp endSheet:exportSheet];
	}
}


@end
