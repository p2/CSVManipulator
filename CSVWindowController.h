//
//  CSVWindowController.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 06.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MyDocument;
@class PPStringFormat;
@class DataTableView;
@class PPToolbarView;


@interface CSVWindowController : NSWindowController
{
	MyDocument *document;
	
	// Main window
	IBOutlet DataTableView *mainTable;
	IBOutlet PPToolbarView *mainToolbar;
	
	IBOutlet NSTextField *numEntriesField;
	IBOutlet NSTextField *importAbortedField;
	
	IBOutlet NSPopUpButton *copyAsKindPopup;
	
	// Export sheet
	IBOutlet NSView *exportAccessoryView;
	
	// Progress window
	IBOutlet NSPanel *progressSheet;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *progressPercentage;
}

@property (nonatomic, assign) MyDocument *document;

@property (nonatomic, retain) IBOutlet DataTableView *mainTable;
@property (nonatomic, retain) IBOutlet PPToolbarView *mainToolbar;

@property (nonatomic, retain) IBOutlet NSView *exportAccessoryView;


// Export Sheet
- (IBAction) exportDocument:(id)sender;
- (NSInteger) outputFormat;

// Data control
- (void) addToCSVRow:(id)sender;
- (void) removeFromCSVRow:(id)sender;

// Display options
- (IBAction) restoreOriginalOrder:(id)sender;
- (void) didRestoreOriginalOrder;

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
