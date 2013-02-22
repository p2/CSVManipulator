//
//  CSVInspector.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 30.08.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
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


#pragma mark - Singleton Overrides
static CSVInspector *inspectorInstance = nil;

+ (CSVInspector *)sharedInspector
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


+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized (self) {
		if (nil == inspectorInstance) {
			return [super allocWithZone:zone];
		}
	}
	
	return inspectorInstance;
}

- (id)init
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

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (NSUInteger)retainCount
{
    return UINT_MAX;
}

- (oneway void)release			// ha, try to release this!
{
}

- (id)autorelease
{
	return self;
}

- (void)dealloc			// will never be called! (Singleton)
{
	self.currentDocument = nil;
	self.documentColumns = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
	[super dealloc];
}



#pragma mark - KVC
- (MyDocument *)currentDocument
{
	return currentDocument;
}
- (void)setCurrentDocument:(MyDocument *)newDocument
{
	if (newDocument != currentDocument) {
		currentDocument = newDocument;
		
		[self willChangeValueForKey:@"documentColumns"];
		self.documentColumns.content = currentDocument.csvDocument.columns;
		[self didChangeValueForKey:@"documentColumns"];
	}
}

- (NSArrayController *)documentColumns
{
	if (nil == documentColumns) {
		self.documentColumns = [[[NSArrayController alloc] init] autorelease];
	}
	return documentColumns;
}
- (void)setDocumentColumns:(NSArrayController *)newColumns
{
	if (newColumns != documentColumns) {
		[self willChangeValueForKey:@"documentColumns"];
		[documentColumns release];
		documentColumns = [newColumns retain];
		[self didChangeValueForKey:@"documentColumns"];
	}
}



#pragma mark - GUI
+ (void)show:(id)sender
{
	CSVInspector *i = [CSVInspector sharedInspector];
	
	i.currentDocument = [[NSDocumentController sharedDocumentController] currentDocument];
	[i showWindow:sender];
}

- (void)awakeFromNib
{
	// DEBUGGING
	[calculationSourceRegExp setStringValue:@"(\\d+)\\.(\\d+)"];
	[calculationTargetExpr setStringValue:@"$1 * $2"];
}

- (NSString *)windowFrameAutosaveName
{
	return @"CSVInspectorMainWindow";
}



#pragma mark - Notifications
- (void)documentBecameActiveNotification:(NSNotification *)notification
{
	MyDocument *document = [notification object];
	self.currentDocument = document;
}

- (void)documentBecameInactiveNotification:(NSNotification *)notification
{
	self.currentDocument = nil;
}

- (void)documentDidChangeColumns:(NSNotification *)notification
{
	[self willChangeValueForKey:@"documentColumns"];
	[self didChangeValueForKey:@"documentColumns"];
}



#pragma mark - Calculations
- (IBAction)performCalculation:(id)sender
{
	if (nil == currentDocument) {
		ALog(@"currentDocument is nil!");
		return;
	}
	
	// should cancel
	if (calculationIsRunning) {
		[currentDocument setCalculationShouldTerminate:YES];
		[self updateCalculationStatus:[NSNumber numberWithInt:1]];
		return;
	}
	
	calculationIsRunning = YES;
	[currentDocument setCalculationShouldTerminate:NO];
	[calculationStartButton setTitle:@"Cancel"];
	[calculationProgress startAnimation:nil];
	
	// get source and target columns
	NSArray *columns = [currentDocument columns];
	NSInteger sourceIndex = [calculationSourcePopup indexOfSelectedItem];
	if (sourceIndex >= 0 && sourceIndex < [columns count]) {
		NSInteger targetIndex = [calculationTargetPopup indexOfSelectedItem];
		if (targetIndex >= 0 && targetIndex < [columns count]) {
			
			// get source/target key and expressions
			NSString *sourceKey = [(CSVColumn *)[columns objectAtIndex:sourceIndex] key];
			NSString *targetKey = [(CSVColumn *)[columns objectAtIndex:targetIndex] key];
			
			NSString *regExp = [calculationSourceRegExp stringValue];
			NSString *expression = [calculationTargetExpr stringValue];
			
			// detach a new thread
			NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
								  sourceKey, kCalculationKeySourceColumn,
								  targetKey, kCalculationKeyTargetColumn,
								  regExp, kCalculationKeySourceRegEx,
								  expression, kCalculationKeyTargetExpression, nil];
			[NSThread detachNewThreadSelector:@selector(performCalculationWithArgs:)
									 toTarget:currentDocument
								   withObject:args];			// args is automatically retained for the duration of the loop	*/
		}
		else {
			ALog(@"Target Column %lu does not exist", (unsigned long)targetIndex);
		}
	}
	else {
		ALog(@"Source Column %lu does not exist", (unsigned long)sourceIndex);
	}
}

- (void)updateCalculationStatus:(NSNumber *)alreadyDone
{
	if ([alreadyDone isLessThan:[NSNumber numberWithInt:1]]) {
		[calculationProgress setDoubleValue:[alreadyDone doubleValue]];
	}
	
	// we've now finished
	else if (calculationIsRunning) {
		[calculationStartButton setTitle:@"Go"];
		[calculationProgress setDoubleValue:1.0];
		[calculationProgress stopAnimation:nil];
		calculationIsRunning = NO;
	}
}


@end
