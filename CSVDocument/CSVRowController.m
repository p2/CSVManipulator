//
//  CSVRowController.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 22.02.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CSVRowController.h"
#import "CSVRow.h"


@implementation CSVRowController

@synthesize document;

- (id) newObject
{
	return [[CSVRow rowForDocument:document] retain];
}


@end
