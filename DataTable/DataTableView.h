//
//  DataTableView.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 22.02.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyDocument.h"
@class CSVRowController;


@interface DataTableView : NSTableView {
	NSArray *sortDescriptorsArray;
}

- (void) drawRow:(NSInteger) rowIndex clipRect:(NSRect) clipRect;

- (void) setSortDescriptors:(NSArray *) array;
- (void) reallySetSortDescriptors;

@end
