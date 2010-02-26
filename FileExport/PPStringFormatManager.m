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
#import "PPStringFormatPreviewController.h"
#import "PPToolbarView.h"
#import "MyDocument.h"
#import "CSVDocument.h"

#define kPluginFormatFileExtension @"exportformat"


@interface PPStringFormatManager ()

@property (nonatomic, readwrite, retain) NSMutableArray *formats;
@property (nonatomic, readwrite, retain) NSArray *systemFormats;
@property (nonatomic, readwrite, retain) PPStringFormatsController *formatController;

- (void) didEndAlert:(NSAlert *)alert withCode:(NSInteger)retCode fromContext:(id)contextInfo;

- (NSString *) formatPluginPath;
- (NSURL *) possiblePathForName:(NSString *)name;
- (BOOL) formatPluginDirectoryExistsOrCreate:(NSError **)outError;

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

@synthesize previewPanelController;


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
	
	self.previewPanelController = nil;
	
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
							  [PPStringFormat sqlFormat],
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



#pragma mark Awakening and Closing
- (void) awakeFromNib
{
	[super awakeFromNib];
	
	formatToolbar.borderWidth = PPBorderWidthMake(1.0, 1.0, 0.0, 0.0);
	
	NSNotification *myNote = [NSNotification notificationWithName:NSTableViewSelectionDidChangeNotification object:formatTable];
	[self tableViewSelectionDidChange:myNote];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidEndEditing:) name:NSTextDidEndEditingNotification object:nil];
	
	// load custom formats
	NSError *error = nil;
	[self loadFormatPlugins:&error];
	if (nil != error) {
		NSLog(@"Error loading plugins: %@", [error localizedDescription]);
	}
}

- (void) windowWillClose:(NSNotification *)notification
{
	NSError *error = nil;
	
	// save custom formats on window close
	for (PPStringFormat *format in [formatController arrangedObjects]) {
		if (!format.isSystemFormat) {
			if (![self formatPluginDirectoryExistsOrCreate:&error] || ![format save:&error]) {
				
				// we currently just log the error...
				NSLog(@"There was an error saving %@: %@", format.name, [error localizedDescription]);
			}
		}
	}
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
- (IBAction) askToRemoveFormat:(id)sender
{
	formatToBeRemoved = [[formatController selectedObjects] objectAtIndex:0];		// Error checking, anyone??
	if (nil != formatToBeRemoved) {
		NSString *alertTitle = [NSString stringWithFormat:@"Delete %@", formatToBeRemoved.name];
		NSAlert *askAlert = [NSAlert alertWithMessageText:alertTitle
											defaultButton:@"Delete"
										  alternateButton:@"Cancel"
											  otherButton:nil
								informativeTextWithFormat:@"This will permanently remove the format %@", formatToBeRemoved.name];
		[askAlert beginSheetModalForWindow:self.window
							 modalDelegate:self
							didEndSelector:@selector(didEndAlert:withCode:fromContext:)
							   contextInfo:@"confirmFormatDeletion"];
	}
}

- (void) didEndAlert:(NSAlert *)alert withCode:(NSInteger)retCode fromContext:(id)contextInfo
{
	// want to remove a format
	if ([contextInfo isEqual:@"confirmFormatDeletion"]) {
		if (NSAlertDefaultReturn == retCode) {
			if (nil != formatToBeRemoved) {
				NSError *error = nil;
				if ([formatToBeRemoved deleteFile:&error]) {
					[formatController removeObject:formatToBeRemoved];
					formatToBeRemoved = nil;
				}
				else if (error != nil) {
					[[alert window] orderOut:nil];
					NSAlert *otherAlert = [NSAlert alertWithError:error];
					[otherAlert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:NULL contextInfo:nil];
				}
			}
			else {
				NSLog(@"Uh-oh, formatToBeRemoved is nil!!");
			}
		}
	}
}

- (IBAction) showPreview:(id)sender
{
	[previewPanelController showWindow:sender];
	[self updatePreview:sender];
}

- (IBAction) updatePreview:(id)sender
{
	if ([previewPanelController.window isVisible]) {
		NSDocumentController *docController = [NSDocumentController sharedDocumentController];
		MyDocument *frontDoc = [docController currentDocument];
		CSVDocument *csvDoc = frontDoc.csvDocument;
		if (nil != csvDoc) {
			
			// get current format
			PPStringFormat *frontFormat = [self selectedFormat];
			if (nil != frontFormat) {
				NSIndexSet *testSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 8)];
				NSError *myError = nil;
				NSString *previewString = [csvDoc stringInFormat:frontFormat withColumns:csvDoc.activeColumns forRowIndexes:testSet includeHeaders:YES  error:&myError];
				
				if (nil != myError) {
					previewString = [myError localizedDescription];
				}
				[previewPanelController previewString:previewString];
			}
			
			// adjust the panel title
			previewPanelController.panelTitle = [NSString stringWithFormat:@"Preview • %@", frontFormat.name];
		}
	}
}

- (IBAction) exportDocument:(id)sender
{
	[[NSApp delegate] exportDocument:sender];
}

- (IBAction) copySelectedFormat:(id)sender
{
	PPStringFormat *selected = [self selectedFormat];
	if (nil != selected) {
		PPStringFormat *copy = [selected copy];
		copy.name = [NSString stringWithFormat:@"%@ copy", selected.name];
		copy.fileURL = [self possiblePathForName:copy.name];
		
		[formatController addObject:copy];
		[copy release];
	}
}

- (IBAction) loadFormatPlugins:(NSError **)outError
{
	NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
	NSString *pluginPath = [self formatPluginPath];
	NSArray *files = [fm contentsOfDirectoryAtPath:pluginPath error:outError];
	
	// we got files, try to open them
	if ([files count] > 0) {
		for (NSString *file in files) {
			if ([[file pathExtension] isEqualToString:kPluginFormatFileExtension]) {
				NSURL *fileURL = [NSURL fileURLWithPath:[pluginPath stringByAppendingPathComponent:file]];
				
				// only instantiate if it's not already open
				BOOL alreadyOpen = NO;
				for (PPStringFormat *openFormat in [formatController arrangedObjects]) {
					if ([openFormat.fileURL isEqual:fileURL]) {
						alreadyOpen = YES;
						break;
					}
				}
				
				// not opened yet - instantiate
				if (!alreadyOpen) {
					PPStringFormat *pluginFormat = [PPStringFormat formatFromFile:fileURL error:outError];
					if (nil != pluginFormat) {
						[formatController addObject:pluginFormat];
					}
				}
			}
		}
	}
}

- (BOOL) installFormat:(NSURL *)source error:(NSError **)outError
{
	if (nil != source) {
		if ([self formatPluginDirectoryExistsOrCreate:outError]) {
			NSString *pluginPath = [self formatPluginPath];
			NSString *fileNameExt = [[[source path] lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			
			// failed replacing percent escape signs
			if (nil == fileNameExt) {
				NSString *err = [NSString stringWithFormat:@"The source path %@ could not be converted to UTF-8", source];
				if (outError) {
					NSDictionary *errorDict = [NSDictionary dictionaryWithObject:err forKey:NSLocalizedDescriptionKey];
					*outError = [NSError errorWithDomain:NSCocoaErrorDomain code:200 userInfo:errorDict];
				}
				else {
					NSLog(@"%@", err);
				}
				return NO;
			}
			NSURL *destinationPath = [NSURL fileURLWithPath:[pluginPath stringByAppendingPathComponent:fileNameExt]];
			
			// is it already at the right spot?
			if ([destinationPath isEqual:source]) {
				[self loadFormatPlugins:outError];
				return YES;
			}
			
			// no; move there!
			NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
			NSString *fileName = [fileNameExt stringByDeletingPathExtension];
			NSString *name = fileName;
			
			// try whether this filename already exists
			NSString *proposedPath = [[pluginPath stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:kPluginFormatFileExtension];
			NSUInteger i = 0;
			while ([fm fileExistsAtPath:proposedPath]) {
				fileName = [NSString stringWithFormat:@"%@-%i", name, ++i];
				proposedPath = [[pluginPath stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:kPluginFormatFileExtension];
			}
			
			// move there
			if ([fm moveItemAtPath:[source path] toPath:proposedPath error:outError]) {
				[self loadFormatPlugins:outError];
				return YES;
			}
			return NO;
		}
	}
	else if (NULL != outError) {
		
	}
	return NO;
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
#pragma mark -



#pragma mark Utilities
- (NSString *) formatPluginPath
{
	return [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Application Support/CSVManipulator/Formats"];
}

- (NSURL *) possiblePathForName:(NSString *)name
{
	NSString *pluginPath = [self formatPluginPath];
	NSString *fileName = name;
	
	NSString *proposedPath = [[pluginPath stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:kPluginFormatFileExtension];
	
	// check if the file exists
	NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
	NSUInteger i = 0;
	while ([fm fileExistsAtPath:proposedPath]) {
		fileName = [NSString stringWithFormat:@"%@-%i", name, ++i];
		proposedPath = [[pluginPath stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:kPluginFormatFileExtension];
	}
	
	return [NSURL fileURLWithPath:proposedPath isDirectory:NO];
}

- (BOOL) formatPluginDirectoryExistsOrCreate:(NSError **)outError
{
	NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
	NSString *path = [self formatPluginPath];
	
	// try to create
	if (![fm fileExistsAtPath:path]) {
		NSError *error = *outError;
		if (![fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
			NSLog(@"Creating plugin directory failed: %@", [error localizedDescription]);
			return NO;
		}
	}
	
	return YES;
}


@end
