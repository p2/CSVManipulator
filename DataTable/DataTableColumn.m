//
//  DataTableColumn.m
//  check
//
//  Created by Pascal Pfiffner on 04.03.08.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import "DataTableColumn.h"
#import "DataTableHeaderCell.h"
#import "DataTableView.h"
#import "CSVColumn.h"


@implementation DataTableColumn

@dynamic active;
@synthesize sortPriority;
@synthesize sortAscending;


+ (void) initialize
{
	[self exposeBinding:@"active"];
}

- (id) init
{
	self = [super init];
	if (nil != self) {
		sortPriority = 1;
		DataTableHeaderCell *headerCell = [[[DataTableHeaderCell alloc] init] autorelease];
		headerCell.myColumn = self;
		[self setHeaderCell:headerCell];
		self.active = YES;
	}
	
	return self;
}

+ (DataTableColumn *) column
{
	return [[[DataTableColumn alloc] init] autorelease];
}
#pragma mark -



#pragma mark KVC
- (BOOL) active
{
	return active;
}
- (void) setActive:(BOOL)newActive
{
	if (newActive != active) {
		active = newActive;
		((DataTableHeaderCell *)[self headerCell]).checked = active;
		[(DataTableView *)[self tableView] columnDidChangeCheckedStatus:self];
	}
}
#pragma mark -



#pragma mark Sorting
- (void) setSortAscending:(BOOL)ascending priority:(NSUInteger)priority
{
	sortAscending = ascending;
	sortPriority = priority;
	
	[(NSControl *)[[self headerCell] controlView] updateCell:[self headerCell]];
}
#pragma mark -



#pragma mark Utilities
- (NSString *) description
{
	return [NSString stringWithFormat:@"%@ <0x%x>, active: %i", NSStringFromClass([self class]), self, active];
}


@end
