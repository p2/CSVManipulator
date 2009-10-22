//
//  CSVWindowController.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 06.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "DataTableViewDelegate.h"
@class MyDocument;
@class PPStringFormat;
@class DataTableView;
@class PPToolbarView;


@interface CSVWindowController : NSWindowController <DataTableViewDelegate>
{
	MyDocument *document;
	
	// Main window
	IBOutlet DataTableView *mainTable;
	IBOutlet PPToolbarView *mainToolbar;
	
	IBOutlet NSTextField *numEntriesField;
	IBOutlet NSTextField *importAbortedField;
	
	IBOutlet NSPopUpButton *copyAsKindPopup;
	
	// Progress window
	IBOutlet NSPanel *progressSheet;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *progressPercentage;
	
	// Export sheet
	IBOutlet NSPanel *exportSheet;
}

@property (nonatomic, assign) MyDocument *document;

@property (nonatomic, retain) IBOutlet DataTableView *mainTable;
@property (nonatomic, retain) IBOutlet PPToolbarView *mainToolbar;

@property (nonatomic, retain) IBOutlet NSPanel *progressSheet;
@property (nonatomic, retain) IBOutlet NSPanel *exportSheet;


// Data control
- (IBAction) addCSVRow:(id)sender;
- (IBAction) removeCSVRow:(id)sender;

// Display options
- (IBAction) restoreOriginalOrder:(id)sender;
- (void) didRestoreOriginalOrder;

// TableView delegate
- (void) redefineTable;
- (void) refreshData;

// Inspector
- (IBAction) showInspector:(id)sender;

// Progress Sheet Actions
- (void) showProgressSheet;
- (void) updateProgressSheetProgress:(CGFloat)percentage;
- (void) hideProgressSheet;
- (IBAction) abortImport:(id)sender;
- (void) didAbortImport:(BOOL)flag;

// Export Sheet
- (IBAction) showExportSheet:(id)sender;
- (IBAction) exportDocument:(id)sender;
- (IBAction) hideExportSheet:(id)sender;



@end
