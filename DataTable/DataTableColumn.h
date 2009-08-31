//
//  DataTableColumn.h
//  check
//
//  Created by Pascal Pfiffner on 04.03.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DataTableHeaderCell;


@interface DataTableColumn : NSTableColumn {
	DataTableHeaderCell *headerCell;
}

@property (nonatomic, retain) DataTableHeaderCell *headerCell;


@end
