//
//  DataTableHeaderCell.h
//  check
//
//  Created by Pascal Pfiffner on 04.03.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DataTableHeaderCell : NSTableHeaderCell {
	BOOL checked;
	NSButtonCell *checkbox;
	NSTextFieldCell *textfield;
}

@property (nonatomic, assign, getter=isChecked) BOOL checked;

- (NSButtonCell *) checkbox;


@end
