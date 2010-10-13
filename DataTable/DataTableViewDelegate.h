//
//  DataTableViewDelegate.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 10/16/09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//


#import <Cocoa/Cocoa.h>
@class DataTableView;
@class DataTableColumn;


@protocol DataTableViewDelegate <NSObject>

@optional

- (void) tableView:(DataTableView *)tableView didChangeTableColumnState:(DataTableColumn *)tableColumn;


@end
