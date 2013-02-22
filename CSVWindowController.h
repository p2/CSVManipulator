//
//  CSVWindowController.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 06.01.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "DataTableView.h"
@class MyDocument;
@class CSVColumn;
@class PPStringFormat;
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
	
	// toolbar items (needed for validation)
	IBOutlet NSToolbarItem *addRowItem;
	IBOutlet NSToolbarItem *removeRowItem;
	IBOutlet NSToolbarItem *addColumnItem;
	IBOutlet NSToolbarItem *removeColumnItem;
	IBOutlet NSToolbarItem *restoreOrderItem;
	IBOutlet NSToolbarItem *showFormatsItem;
	
	// Progress window
	IBOutlet NSPanel *progressSheet;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *progressPercentage;
}

@property (nonatomic, assign) MyDocument *document;

@property (nonatomic, retain) IBOutlet DataTableView *mainTable;
@property (nonatomic, retain) IBOutlet PPToolbarView *mainToolbar;
@property (nonatomic, retain) NSToolbarItem *addRowItem;
@property (nonatomic, retain) NSToolbarItem *removeRowItem;
@property (nonatomic, retain) NSToolbarItem *addColumnItem;
@property (nonatomic, retain) NSToolbarItem *removeColumnItem;
@property (nonatomic, retain) NSToolbarItem *restoreOrderItem;
@property (nonatomic, retain) NSToolbarItem *showFormatsItem;

@property (nonatomic, retain) IBOutlet NSPanel *progressSheet;


// Row/Column control
- (IBAction)addNewColumn:(id)sender;
- (IBAction)removeSelectedColumns:(id)sender;
- (IBAction)addCSVRow:(id)sender;
- (IBAction)removeCSVRow:(id)sender;

// Display options
- (IBAction)restoreOriginalOrder:(id)sender;
- (void)didRestoreOriginalOrder;

// TableView delegate
- (void)redefineTable;
- (void)addColumn:(CSVColumn *)newColumn toTable:(NSTableView *)aTableView atPosition:(NSUInteger)position withWidth:(CGFloat)width resizeTable:(BOOL)resize;
- (void)refreshData;

// Inspector
- (IBAction)showInspector:(id)sender;

// Progress Sheet Actions
- (void)showProgressSheet;
- (void)updateProgressSheetProgress:(CGFloat)percentage;
- (void)setProgressSheetIndeterminate:(NSNumber *)flag;
- (void)hideProgressSheet;
- (IBAction)abortImport:(id)sender;
- (void)didAbortImport:(BOOL)flag;

// Export Sheet
- (IBAction)showExportFormats:(id)sender;


@end
