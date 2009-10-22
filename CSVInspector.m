//
//  CSVInspector.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 30.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CSVInspector.h"
#import "RegexKitLite.h"


@implementation CSVInspector


#pragma mark Singleton Overrides
static CSVInspector *inspectorInstance = nil;

+ (CSVInspector *) sharedInspector
{
	@synchronized (self) {
		if (nil == inspectorInstance ) {
			[[self alloc] init];
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

- (void) dealloc			// will never be called anyway! (Singleton)
{
	[super dealloc];
}
#pragma mark -



#pragma mark GUI
+ (void) show:(id)sender
{
	CSVInspector *i = [CSVInspector sharedInspector];
	
	while (nil == [i window]) {
		usleep(50);
	}
	
	[[i window] makeKeyAndOrderFront:sender];
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



#pragma mark Calculations
- (IBAction) performCalculation:(id)sender
{
	// should cancel
	if(calculationIsRunning) {
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
