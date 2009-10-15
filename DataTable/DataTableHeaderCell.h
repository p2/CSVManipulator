//
//  DataTableHeaderCell.h
//  check
//
//  Created by Pascal Pfiffner on 04.03.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DataTableHeaderCell : NSTableHeaderCell {
	BOOL showsCheckbox;
	BOOL checked;
	NSButtonCell *headerCheckbox;
	NSTextFieldCell *headerTextfield;
	NSRect headerCheckboxRect;
	
	NSUInteger sortPriority;			// needed to keep track of the sort state
	BOOL sortAscending;					// needed to keep track of the sort state
}

@property (nonatomic, assign) BOOL showsCheckbox;
@property (nonatomic, assign, getter=isChecked) BOOL checked;
@property (nonatomic, retain) NSButtonCell *headerCheckbox;
@property (nonatomic, retain) NSTextFieldCell *headerTextfield;
@property (nonatomic, readonly) BOOL sortAscending;

-(void) setSortAscending:(BOOL)ascending priority:(NSUInteger)priority;			// needed to show sort state of the column


@end
