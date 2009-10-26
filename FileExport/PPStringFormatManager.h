//
//  PPStringFormatManager.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 10/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PPToolbarView;


@interface PPStringFormatManager : NSWindowController {
	NSArray *systemFormats;
	NSArray *userFormats;
	NSArrayController *formats;
	
	IBOutlet PPToolbarView *formatToolbar;
}

@property (nonatomic, readonly, retain) NSArray *systemFormats;
@property (nonatomic, readwrite, retain) NSArray *userFormats;
@property (nonatomic, readonly, retain) NSArrayController *formats;

@property (nonatomic, retain) IBOutlet PPToolbarView *formatToolbar;

+ (PPStringFormatManager *) sharedManager;
+ (void) show:(id)sender;


@end
