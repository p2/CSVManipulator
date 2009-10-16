//
//  DataTableHeaderCell.h
//  check
//
//  Created by Pascal Pfiffner on 04.03.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DataTableColumn;


@interface DataTableHeaderCell : NSTableHeaderCell {
	DataTableColumn *myColumn;
	
	BOOL showsCheckbox;
	BOOL checked;
	NSButtonCell *headerCheckbox;
	NSTextFieldCell *headerTextfield;
	NSRect headerCheckboxRect;
}

@property (nonatomic, assign) DataTableColumn *myColumn;
@property (nonatomic, assign) BOOL showsCheckbox;
@property (nonatomic, assign, getter=isChecked) BOOL checked;
@property (nonatomic, retain) NSButtonCell *headerCheckbox;
@property (nonatomic, retain) NSTextFieldCell *headerTextfield;


@end
