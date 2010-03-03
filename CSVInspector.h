//
//  CSVInspector.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 30.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MyDocument;


@interface CSVInspector : NSWindowController {
	MyDocument *currentDocument;
	NSArrayController *documentColumns;
	
	IBOutlet NSPopUpButton *calculationSourcePopup;			// the popup to choose the source column
	IBOutlet NSPopUpButton *calculationTargetPopup;			// the popup to choose the target column
	IBOutlet NSTextField *calculationSourceRegExp;			// the text field to define the source RegExp
	IBOutlet NSTextField *calculationTargetExpr;			// the text field to define the target expression
	IBOutlet NSButton *calculationStartButton;				// the "Go" button (changes to "Cancel")
	IBOutlet NSProgressIndicator *calculationProgress;		// the progress indicator
	
	BOOL calculationIsRunning;
}

@property (nonatomic, assign) MyDocument *currentDocument;

+ (CSVInspector *) sharedInspector;
+ (void) show:(id)sender;

- (void) documentBecameActiveNotification:(NSNotification *)notification;
- (void) documentBecameInactiveNotification:(NSNotification *)notification;
- (void) documentDidChangeColumns:(NSNotification *)notification;


- (IBAction) performCalculation:(id)sender;
- (void) updateCalculationStatus:(NSNumber *)alreadyDone;


@end
