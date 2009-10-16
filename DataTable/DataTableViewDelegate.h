//
//  DataTableViewDelegate.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 10/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
@class DataTableView;
@class DataTableColumn;


@protocol DataTableViewDelegate <NSObject>

@optional

- (void) tableView:(DataTableView *)tableView didChangeTableColumnState:(DataTableColumn *)tableColumn;


@end
