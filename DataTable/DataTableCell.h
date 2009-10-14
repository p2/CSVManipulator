//
//  DataTableCell.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 09.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DataTableCell : NSTextFieldCell {
	BOOL isTitleCell;
}

@property (nonatomic, assign) BOOL isTitleCell;

+ (DataTableCell *) cell;


@end
