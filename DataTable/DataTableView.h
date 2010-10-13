//
//  DataTableView.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 22.02.08.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
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
