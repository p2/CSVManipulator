//
//  CSVInspector.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 30.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CSVInspector.h"
#import "RegexKitLite.h"
#import "MyDocument.h"
#import "CSVDocument.h"
#import "CSVColumn.h"


@interface CSVInspector ()

@property (nonatomic, readwrite, retain) NSArrayController *documentColumns;

@end


@implementation CSVInspector

@dynamic currentDocument;
@dynamic documentColumns;


#pragma mark Singleton Overrides
static CSVInspector *inspectorInstance = nil;

+ (CSVInspector *) sharedInspector
{
	@synchronized (self) {
		if (nil == inspectorInstance ) {
			[[self alloc] init];
			
			NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
			
			[center addObserver:inspectorInstance
					   selector:@selector(documentBecameActiveNotification:)
						   name:kDocumentDidBecomeActive
						 object:nil];
			
			[center addObserver:inspectorInstance
					   selector:@selector(documentBecameInactiveNotification:)
						   name:kDocumentDidBecomeInactive
						 object:nil];
			
			[center addObserver:inspectorInstance
					   selector:@selector(documentDidChangeColumns:)
						   name:kDocumentDidChangeColumns
						 object:nil];
		}
	}
	
	return inspectorInstance;
}


+ (id) allocWithZone:(NSZone *)zone
{
	@synchronized (self) {
		if (nil == inspectorInstance) {
			return [super allocWithZone:zone];
		}
	}
	
	return inspectorInstance;
}

- (id) init
{
	Class myClass = [self class];
	@synchronized (myClass) {
		if (nil == inspectorInstance) {
			
			// create the inspector
			if (self = [super initWithWindowNibName:@"CSVInspector"]) {
				inspectorInstance = self;
			}
		}
	}
	
	return inspectorInstance;
}

- (id) copyWithZone:(NSZone *)zone
{
	return self;
}

- (id) retain
{
	return self;
}

- (unsigned) retainCount
{
    return UINT_MAX;
}

- (void) release			// ha, try to release this!
{
}

- (id) autorelease
{
	return self;
}

- (void) dealloc			// will never be called! (Singleton)
{
	self.currentDocument = nil;
	self.documentColumns = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
	[super dealloc];
}
#pragma mark -



#pragma mark KVC
- (MyDocument *) currentDocument
{
	return currentDocument;
}
- (void) setCurrentDocument:(MyDocument *)newDocument
{
	if (newDocument != currentDocument) {
		currentDocument = newDocument;
		
		[self willChangeValueForKey:@"documentColumns"];
		self.documentColumns.content = currentDocument.csvDocument.columns;
		[self didChangeValueForKey:@"documentColumns"];
	}
}

- (NSArrayController *) documentColumns
{
	if (nil == documentColumns) {
		self.documentColumns = [[[NSArrayController alloc] init] autorelease];
	}
	return documentColumns;
}
- (void) setDocumentColumns:(NSArrayController *)newColumns
{
	if (newColumns != documentColumns) {
		[self willChangeValueForKey:@"documentColumns"];
		[documentColumns release];
		documentColumns = [newColumns retain];
		[self didChangeValueForKey:@"documentColumns"];
	}
}
#pragma mark -



#pragma mark GUI
+ (void) show:(id)sender
{
	CSVInspector *i = [CSVInspector sharedInspector];
	
	i.currentDocument = [[NSDocumentController sharedDocumentController] currentDocument];
	[i showWindow:sender];
}

- (void) awakeFromNib
{
	// DEBUGGING
	[calculationSourceRegExp setStringValue:@"(\\d+)\\.(\\d+)"];
	[calculationTargetExpr setStringValue:@"$1 * $2"];
}

- (NSString *) windowFrameAutosaveName
{
	return @"CSVInspectorMainWindow";
}
#pragma mark -



#pragma mark Notifications
- (void) documentBecameActiveNotification:(NSNotification *)notification
{
	MyDocument *document = [notification object];
	self.currentDocument = document;
}

- (void) documentBecameInactiveNotification:(NSNotification *)notification
{
	self.currentDocument = nil;
}

- (void) documentDidChangeColumns:(NSNotification *)notification
{
	[self willChangeValueForKey:@"documentColumns"];
	[self didChangeValueForKey:@"documentColumns"];
}
#pragma mark -



#pragma mark Calculations
- (IBAction) performCalculation:(id)sender
{
	// should cancel
	if (calculationIsRunning) {
//		[document setCalculationShouldTerminate:YES];
		return;
	}
	
	calculationIsRunning = YES;
//	[document setCalculationShouldTerminate:NO];
	[calculationStartButton setTitle:@"Cancel"];
	[calculationProgress startAnimation:nil];
	/*
	//--
	NSString *sourceKey = [[[calculationSourcePopup selectedItem] title] stringByMatching:@"\\(([^\\(\\)]+)\\)$" capture:1];
	NSString *targetKey = [[[calculationTargetPopup selectedItem] title] stringByMatching:@"\\(([^\\(\\)]+)\\)$" capture:1];
	//--
	NSString *regExp = [calculationSourceRegExp stringValue];
	NSString *expression = [calculationTargetExpr stringValue];
	/*
	// detach a new thread
	NSDictionary *args = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:sourceKey, targetKey, regExp, expression, nil]
													 forKeys:[NSArray arrayWithObjects:@"sourceKey", @"targetKey", @"regExp", @"expression", nil]];
	
	[NSThread detachNewThreadSelector:@selector(performCalculationWithArgs:)
							 toTarget:document
						   withObject:args];			// args is automatically retained for the duration of the loop	*/
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
}


@end
