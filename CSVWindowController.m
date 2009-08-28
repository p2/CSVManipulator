//
//  CSVWindowController.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 06.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CSVWindowController.h"
#import "MyDocument.h"
#import "CSVDocument.h"
#import "CSVColumn.h"
#import "DataTableView.h"
#import "DataTableColumn.h"
#import "DataTableHeaderCell.h"
#import "PPToolbarView.h"
#import "RegexKitLite.h"

#define COLUMN_MIN_WIDTH 40


@implementation CSVWindowController

@synthesize document;
@synthesize mainTable;
@synthesize mainToolbar;


- (id) init
{
	self = [super init];
	if(nil != self) {
		
	}
	
	return self;
}

- (void) dealloc
{
	self.document = nil;
	
	self.mainTable = nil;
	self.mainToolbar = nil;
	
	[super dealloc];
}

- (void) awakeFromNib
{
	NSNumber *top_border_width = [NSNumber numberWithInt:1];
	mainToolbar.borderWidths = [NSArray arrayWithObjects:top_border_width, [NSNull null], [NSNull null], [NSNull null], nil];
	[document awokeFromNib];
	
	// DEBUGGING
	[calculationSourceRegExp setStringValue:@"(\\d+)\\.(\\d+)"];
	[calculationTargetExpr setStringValue:@"$1 * $2"];
}

- (void) windowWillClose:(NSNotification *)notification
{
	[document setLastChoiceFormat:[self outputFormat]];
}
#pragma mark -



#pragma mark Actions
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



#pragma mark Calculations
- (IBAction) performCalculation:(id)sender
{
	// should cancel
	if(calculationIsRunning) {
		[document setCalculationShouldTerminate:YES];
		return;
	}
	
	calculationIsRunning = YES;
	[document setCalculationShouldTerminate:NO];
	[calculationStartButton setTitle:@"Cancel"];
	[calculationProgress startAnimation:nil];
	
	//--
	NSString *sourceKey = [[[calculationSourcePopup selectedItem] title] stringByMatching:@"\\(([^\\(\\)]+)\\)$" capture:1];
	NSString *targetKey = [[[calculationTargetPopup selectedItem] title] stringByMatching:@"\\(([^\\(\\)]+)\\)$" capture:1];
	//--
	NSString *regExp = [calculationSourceRegExp stringValue];
	NSString *expression = [calculationTargetExpr stringValue];
	
	// detach a new thread
	NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:sourceKey, targetKey, regExp, expression, nil]
													 forKeys:[NSArray arrayWithObjects:@"sourceKey", @"targetKey", @"regExp", @"expression", nil]];
	
	[NSThread detachNewThreadSelector:@selector(performCalculationWithArgs:)
							 toTarget:document
						   withObject:args];			// args is automatically retained for the duration of the loop
}

- (void) updateCalculationStatus:(NSNumber *)alreadyDone
{
	if ([alreadyDone isLessThan:[NSNumber numberWithInt:100]]) {
		[calculationProgress setDoubleValue:[alreadyDone doubleValue]];
	}
	
	// we've now finished
	else if (calculationIsRunning) {
		[calculationStartButton setTitle:@"Go"];
		[calculationProgress stopAnimation:nil];
		calculationIsRunning = NO;
	}
	
	[self refreshData];
}
#pragma mark -



#pragma mark TableView Delegate
- (void) redefineTable
{
	// remove OLD columns
	for (NSTableColumn *oldColumn in [mainTable tableColumns]) {
		[mainTable removeTableColumn:oldColumn];
	}
	
	// clean popups
	[calculationSourcePopup removeAllItems];
	[calculationTargetPopup removeAllItems];
	
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
			[calculationSourcePopup addItemWithTitle:[NSString stringWithFormat:@"%@ (%@)", column.name, column.key]];
			[calculationTargetPopup addItemWithTitle:[NSString stringWithFormat:@"%@ (%@)", column.name, column.key]];
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
		
//		[document setColumnOrder:arr];
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
	[NSApp beginSheet:progressSheet modalForWindow:[self window] modalDelegate:nil didEndSelector:NULL contextInfo:nil];
}

- (void) updateProgressSheetProgress:(CGFloat)percentage
{
	if ([progressSheet isVisible]) {
		[progressIndicator setDoubleValue:(double)percentage];
		[progressPercentage setFloatValue:percentage];
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
