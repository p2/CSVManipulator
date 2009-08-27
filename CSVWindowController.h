//
//  CSVWindowController.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 06.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MyDocument;
@class DataTableView;


@interface CSVWindowController : NSWindowController
{
	MyDocument *document;
	
	// Progress Window
	IBOutlet NSPanel *progressSheet;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *progressPercentage;
	
	// Main Window
	IBOutlet DataTableView *mainTable;
	
	IBOutlet NSTextField *numEntriesField;
	IBOutlet NSTextField *importAbortedField;
	IBOutlet NSPopUpButton *calculationSourcePopup;			// the popup to choose the source column
	IBOutlet NSPopUpButton *calculationTargetPopup;			// the popup to choose the target column
	IBOutlet NSTextField *calculationSourceRegExp;			// the text field to define the source RegExp
	IBOutlet NSTextField *calculationTargetExpr;			// the text field to define the target expression
	IBOutlet NSButton *calculationStartButton;				// the "Go" button (changes to "Cancel")
	IBOutlet NSProgressIndicator *calculationProgress;		// the progress indicator
	IBOutlet NSPopUpButton *copyAsKindPopup;
	
	BOOL calculationIsRunning;
}

@property (nonatomic, assign) MyDocument *document;


- (NSInteger) outputFormat;

// Data control
- (void) addToCSVRow:(id)sender;
- (void) removeFromCSVRow:(id)sender;

// Display options and calculations
- (IBAction) restoreOriginalOrder:(id)sender;
- (void) didRestoreOriginalOrder;
- (IBAction) performCalculation:(id)sender;
- (void) updateCalculationStatus:(NSNumber *)alreadyDone;

// TableView delegate
- (void) redefineTable;
- (void) tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn;
- (void) refreshData;

// Progress Sheet Actions
- (void) showProgressSheet;
- (void) updateProgressSheetProgress:(CGFloat)percentage;
- (void) hideProgressSheet;
- (IBAction) abortImport:(id)sender;
- (void) didAbortImport:(BOOL)flag;


@end
