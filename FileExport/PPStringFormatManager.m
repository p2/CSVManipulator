//
//  PPStringFormatManager.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 10/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PPStringFormatManager.h"
#import "PPStringFormat.h"
#import "PPStringFormatsController.h"
#import "PPToolbarView.h"
#import "MyDocument.h"
#import "CSVDocument.h"


@interface PPStringFormatManager ()

@property (nonatomic, readwrite, retain) NSMutableArray *formats;
@property (nonatomic, readwrite, retain) NSArray *systemFormats;
@property (nonatomic, readwrite, retain) PPStringFormatsController *formatController;

@property (nonatomic, readwrite, retain) NSDictionary *previewAttributes;

@end


@implementation PPStringFormatManager

@dynamic formats;
@dynamic systemFormats;
@synthesize formatController;
@dynamic selectedFormat;

@synthesize systemFormatDetails;
@synthesize userFormatDetails;
@synthesize formatTable;
@synthesize formatToolbar;

@synthesize previewPanel;
@synthesize previewField;
@synthesize previewAttributes;


#pragma mark Singleton Overrides
static PPStringFormatManager *managerInstance = nil;

+ (PPStringFormatManager *) sharedManager
{
	@synchronized (self) {
		if (nil == managerInstance ) {
			[[self alloc] init];
		}
	}
	
	return managerInstance;
}


+ (id) allocWithZone:(NSZone *)zone
{
	@synchronized (self) {
		if (nil == managerInstance) {
			return [super allocWithZone:zone];
		}
	}
	
	return managerInstance;
}

- (id) init
{
	Class myClass = [self class];
	@synchronized (myClass) {
		if (nil == managerInstance) {
			
			// create the manager
			if (self = [super initWithWindowNibName:@"PPStringFormatManager"]) {
				[self formats];
				managerInstance = self;
			}
		}
	}
	
	return managerInstance;
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
	self.systemFormatDetails = nil;
	self.userFormatDetails = nil;
	self.formatTable = nil;
	self.formatToolbar = nil;
	
	self.previewPanel = nil;
	self.previewField = nil;
	
	[super dealloc];
}
#pragma mark -



#pragma mark KVC
- (NSMutableArray *) formats
{
	if (nil == formats) {
		self.formats = [NSMutableArray arrayWithArray:self.systemFormats];
	}
	return formats;
}
- (void) setFormats:(NSMutableArray *)newFormats
{
	if (newFormats != formats) {
		[self willChangeValueForKey:@"formats"];
		[formats release];
		formats = [newFormats retain];
		[self didChangeValueForKey:@"formats"];
	}
}

- (NSArray *) systemFormats
{
	if (nil == systemFormats) {
		self.systemFormats = [NSArray arrayWithObjects:
							  [PPStringFormat csvFormat],
							  [PPStringFormat tabFormat],
							  [PPStringFormat flatXMLFormat],
							  nil];
	}
	return systemFormats;
}
- (void) setSystemFormats:(NSArray *)newFormats
{
	if (newFormats != systemFormats) {
		[systemFormats release];
		systemFormats = [newFormats retain];
	}
}

- (PPStringFormat *) selectedFormat
{
	NSArray *selectedObjects = [formatController selectedObjects];
	if ([selectedObjects count] > 0) {
		return [selectedObjects objectAtIndex:0];
	}
	return nil;
}
#pragma mark -



#pragma mark Awakening
- (void) awakeFromNib
{
	[super awakeFromNib];
	
	formatToolbar.borderWidth = PPBorderWidthMake(1.0, 1.0, 0.0, 0.0);
	
	NSNotification *myNote = [NSNotification notificationWithName:NSTableViewSelectionDidChangeNotification object:formatTable];
	[self tableViewSelectionDidChange:myNote];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidEndEditing:) name:NSTextDidEndEditingNotification object:nil];
}
#pragma mark -



#pragma mark Table and Text Delegate
- (void) tableViewSelectionDidChange:(NSNotification *)aNotification
{
	// change the subview accordingly
	if (formatTable == aNotification.object) {
		if ([self selectedFormat]) {
			BOOL isSystemFormat = [self selectedFormat].isSystemFormat;
			[[detailContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
			
			NSView *newSubview = isSystemFormat ? systemFormatDetails : userFormatDetails;
			newSubview.frame = NSInsetRect(detailContainer.bounds, 5.0, 5.0);
			[detailContainer addSubview:newSubview];
			
			[self updatePreview:nil];
		}
	}
}

- (void) controlTextDidEndEditing:(NSNotification *)aNotification
{
	[self updatePreview:nil];
}
#pragma mark -



#pragma mark Actions
- (IBAction) showPreview:(id)sender
{
	[previewPanel orderFront:sender];
	[previewField setFont:[NSFont fontWithName:@"Monaco" size:12.0]];
	[self updatePreview:sender];
}

- (IBAction) updatePreview:(id)sender
{
	if (nil != previewPanel && [previewPanel isVisible]) {
		NSDocumentController *docController = [NSDocumentController sharedDocumentController];
		MyDocument *frontDoc = [docController currentDocument];
		CSVDocument *csvDoc = frontDoc.csvDocument;
		if (nil != csvDoc) {
			
			// get current format
			PPStringFormat *frontFormat = [self selectedFormat];
			if (nil != frontFormat) {
				NSIndexSet *testSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 8)];
				NSString *previewString = [csvDoc stringInFormat:frontFormat withColumns:csvDoc.activeColumns forRowIndexes:testSet includeHeaders:YES];
				
				[previewField setString:previewString];
			}
			
			// adjust the panel title
			[previewPanel setTitle:[NSString stringWithFormat:@"Preview • %@", frontFormat.name]];
		}
	}
}

- (IBAction) copySelectedFormat:(id)sender
{
	PPStringFormat *selected = [self selectedFormat];
	if (nil != selected) {
		PPStringFormat *copy = [selected copy];
		copy.name = [NSString stringWithFormat:@"%@ copy", selected.name];
		[formatController addObject:copy];
		[copy release];
	}
}
#pragma mark -



#pragma mark Showing/Hiding
+ (void) show:(id)sender
{
	PPStringFormatManager *manager = [PPStringFormatManager sharedManager];
	
	while (nil == [manager window]) {
		usleep(50);
	}
	
	[[manager window] makeKeyAndOrderFront:sender];
}

- (NSString *) windowFrameAutosaveName
{
	return @"PPStringFormatManager";
}


@end
