//
//  DataTableView.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 22.02.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyDocument.h"
@class DataTableColumn;


@interface DataTableView : NSTableView {
	NSArray *sortDescriptorsArray;
	NSInteger titleRowColumnIndex;			// we ask this column's value wether we are a title row which has a different background
}

@property (nonatomic, assign) NSInteger titleRowColumnIndex;

- (void) setSortDescriptorsWithColumn:(DataTableColumn *)tableColumn;
- (void) columnDidChangeCheckedStatus:(DataTableColumn *)tableColumn;
- (NSColor *) titleColorForRow:(NSInteger)rowIndex;

@end
