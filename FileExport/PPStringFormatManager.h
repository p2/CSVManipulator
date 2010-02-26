//
//  PPStringFormatManager.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 10/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PPStringFormatsController;
@class PPStringFormat;
@class PPStringFormatPreviewController;
@class PPToolbarView;


@interface PPStringFormatManager : NSWindowController {
	NSMutableArray *formats;
	NSArray *systemFormats;
	IBOutlet PPStringFormatsController *formatController;
	PPStringFormat *selectedFormat;
	PPStringFormat *formatToBeRemoved;
	
	// main views
	IBOutlet NSView *detailContainer;
	IBOutlet NSView *systemFormatDetails;
	IBOutlet NSView *userFormatDetails;
	
	// outlets
	IBOutlet NSTableView *formatTable;
	IBOutlet PPToolbarView *formatToolbar;
	
	// preview
	IBOutlet PPStringFormatPreviewController *previewPanelController;
}

@property (nonatomic, readonly, retain) NSMutableArray *formats;
@property (nonatomic, readonly, retain) NSArray *systemFormats;
@property (nonatomic, readonly, retain) IBOutlet PPStringFormatsController *formatController;
@property (nonatomic, readonly) PPStringFormat *selectedFormat;

@property (nonatomic, retain) IBOutlet NSView *systemFormatDetails;
@property (nonatomic, retain) IBOutlet NSView *userFormatDetails;
@property (nonatomic, retain) IBOutlet NSTableView *formatTable;
@property (nonatomic, retain) IBOutlet PPToolbarView *formatToolbar;

@property (nonatomic, retain) IBOutlet NSWindowController *previewPanelController;


+ (PPStringFormatManager *) sharedManager;
+ (void) show:(id)sender;

- (IBAction) askToRemoveFormat:(id)sender;

- (IBAction) showPreview:(id)sender;
- (IBAction) updatePreview:(id)sender;
- (IBAction) exportDocument:(id)sender;
- (IBAction) copySelectedFormat:(id)sender;

- (IBAction) loadFormatPlugins:(NSError **)outError;
- (BOOL) installFormat:(NSURL *)path error:(NSError **)outError;


@end
