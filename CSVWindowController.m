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
#import "PPStringFormatManager.h"
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
- (IBAction) addCSVColumn:(id)sender
{
	CSVColumn *newColumn = [CSVColumn columnWithKey:[document.csvDocument nextAvailableColumnKey]];
	if ([document.csvDocument addColumn:newColumn]) {
		[self addColumn:newColumn toTable:mainTable withWidth:0.f];
		document.documentEdited = YES;
	}
}

- (IBAction) removeCSVColumn:(id)sender
{
	NSIndexSet *indexes = [mainTable selectedColumnIndexes];
	if ([indexes count] > 0) {
		NSArray *exColumns = [[mainTable tableColumns] objectsAtIndexes:indexes];
		
		for (NSTableColumn *tableColumn in exColumns) {
			CSVColumn *csvColumn = [document.csvDocument columnWithKey:[tableColumn identifier]];
			if ([document.csvDocument removeColumn:csvColumn]) {
				[mainTable removeTableColumn:tableColumn];
			}
			else {
				NSLog(@"Can't remove column %@ as it is not a valid column", csvColumn.key);
			}
		}
		
		[mainTable sizeLastColumnToFit];
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
	[firstTableColumn setIdentifier:@"_theHeaderRowColumn"];
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
			   withKeyPath:@"arrangedObjects.headerRow"
				   options:nil];
	
	// new headers, new bindings
	NSInteger numColumns = [document numColumns];
	if (numColumns > 0) {
		NSRect mainTableBounds = [mainTable frame];
		int columnWidth = ceilf((mainTableBounds.size.width - firstColumnWidth) / numColumns);
		columnWidth = (columnWidth < COLUMN_MIN_WIDTH) ? COLUMN_MIN_WIDTH : columnWidth;
		
		// loop columns to add the columns
		for (CSVColumn *column in [document columns]) {
			[self addColumn:column toTable:mainTable withWidth:columnWidth];
		}
		
		[mainTable sizeLastColumnToFit];
	}
}

- (void) addColumn:(CSVColumn *)newColumn toTable:(NSTableView *)aTableView withWidth:(CGFloat)width
{
	if (aTableView == mainTable) {
		
		// add the table column
		DataTableColumn *tableColumn = [DataTableColumn column];
		[tableColumn setIdentifier:newColumn.key];
		[tableColumn setDataCell:[DataTableCell cell]];
		[tableColumn setMinWidth:COLUMN_MIN_WIDTH];
		if (width > COLUMN_MIN_WIDTH) {
			[tableColumn setWidth:width];
		}
		[[tableColumn headerCell] setEditable:YES];
		[[tableColumn headerCell] setChecked:newColumn.active];
		
		[mainTable addTableColumn:tableColumn];
		
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


- (void) tableView:(NSTableView *)tableView didDragTableColumn:(NSTableColumn *)tableColumn
{
	if (mainTable == tableView) {
		NSMutableArray *arr = document.csvDocument.columns;
		
		// propagate changes to CSVDocument
		for (DataTableColumn *col in [tableView tableColumns]) {
			CSVColumn *csvCol = [document.csvDocument.columnDict objectForKey:[col identifier]];
			if (nil != csvCol) {
				[arr addObject:csvCol];
			}
		}
		
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


@end
