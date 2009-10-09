//
//  CSVColumn.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 24.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CSVColumn.h"


@implementation CSVColumn

@synthesize key, active;
@dynamic name;


+ (id) columnWithKey:(NSString *)newKey
{
	CSVColumn *column = [[[self alloc] init] autorelease];
	column.key = newKey;
	
	return column;
}

- (void) dealloc
{
	self.key = nil;
	self.name = nil;
	
	[super dealloc];
}
#pragma mark -



#pragma mark KVC
- (NSString *) name
{
	return (nil == name) ? @"" : name;
}
- (void) setName:(NSString *)newName
{
	if (newName != name) {
		[self willChangeValueForKey:@"name"];
		[name release];
		name = [newName retain];
		[self didChangeValueForKey:@"name"];
	}
}

- (BOOL) hasName
{
	return (nil != name && ![@"" isEqualToString:name]);
}
#pragma mark -



#pragma mark Utilities
- (NSString *) description
{
	return [NSString stringWithFormat:@"%@ <0x%X>; %@ -> %@, active: %i", NSStringFromClass([self class]), self, key, name, active];
}


@end
