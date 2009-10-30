//
//  PPStringFormatsController.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 10/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PPStringFormatsController.h"
#import "PPStringFormat.h"


@implementation PPStringFormatsController


- (void) dealloc
{
	[super dealloc];
}
#pragma mark -



#pragma mark Array States
- (void) addObject:(id)object
{
	[self willChangeValueForKey:@"canRemoveSelectedObjects"];
	[super addObject:object];
	[self didChangeValueForKey:@"canRemoveSelectedObjects"];
}

- (BOOL) setSelectionIndexes:(NSIndexSet *)indexes
{
	[self willChangeValueForKey:@"canRemoveSelectedObjects"];
	BOOL flag = [super setSelectionIndexes:indexes];
	[self didChangeValueForKey:@"canRemoveSelectedObjects"];
	return flag;
}

- (BOOL) canRemoveSelectedObjects
{
	BOOL flag = [super canRemove];
	if (flag) {
		for (PPStringFormat *format in [self selectedObjects]) {
			if (format.isSystemFormat) {
				return NO;
			}
		}
	}
	return flag;
}
#pragma mark -



#pragma mark KVO
- (Class) objectClass
{
	return [PPStringFormat class];
}

//+ (NSSet *) keyPathsForValuesAffectingCanRemoveSelectedObjects		// seems to not work, see; http://www.mail-archive.com/cocoa-dev@lists.apple.com/msg40710.html
//{
//	return [NSSet setWithObjects:@"contentArray", @"selectionIndex", @"selectionIndexes", nil];
//}



@end
