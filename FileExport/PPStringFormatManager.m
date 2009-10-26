//
//  PPStringFormatManager.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 10/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PPStringFormatManager.h"
#import "PPStringFormat.h"
#import "PPToolbarView.h"


@interface PPStringFormatManager ()

@property (nonatomic, readwrite, retain) NSArray *systemFormats;
@property (nonatomic, readwrite, retain) NSArrayController *formats;

@end


@implementation PPStringFormatManager

@dynamic systemFormats;
@synthesize userFormats;
@dynamic formats;

@synthesize formatToolbar;


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
	self.formatToolbar = nil;
	
	[super dealloc];
}
#pragma mark -



#pragma mark KVC
- (NSArray *) systemFormats
{
	if (nil == systemFormats) {
		systemFormats = [NSArray arrayWithObjects:
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

- (NSArrayController *) formats
{
	if (nil == formats) {
		self.formats = [[[NSArrayController alloc] initWithContent:self.systemFormats] autorelease];
	}
	return formats;
}
- (void) setFormats:(NSArrayController *)newController
{
	if (newController != formats) {
		[formats release];
		formats = [newController retain];
	}
}
#pragma mark -



#pragma mark Awakening
- (void) awakeFromNib
{
	[super awakeFromNib];
	
	formatToolbar.borderWidth = PPBorderWidthMake(1.0, 1.0, 0.0, 0.0);
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


@end
