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
}

- (void) setSortDescriptors:(NSArray *) array;
- (void) reallySetSortDescriptorsWithColumn:(DataTableColumn *)tableColumn;


@end
