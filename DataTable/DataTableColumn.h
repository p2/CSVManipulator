//
//  DataTableColumn.h
//  check
//
//  Created by Pascal Pfiffner on 04.03.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DataTableColumn : NSTableColumn {
	BOOL active;
	NSUInteger sortPriority;			// needed to keep track of the sort state
	BOOL sortAscending;					// needed to keep track of the sort state
}

@property (nonatomic, assign) BOOL active;
@property (nonatomic, readonly) NSUInteger sortPriority;
@property (nonatomic, readonly) BOOL sortAscending;

+ (DataTableColumn *) column;

-(void) setSortAscending:(BOOL)ascending priority:(NSUInteger)priority;			// needed to show sort state of the column


@end
