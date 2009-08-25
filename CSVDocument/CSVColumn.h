//
//  CSVColumn.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 24.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CSVColumn : NSObject {
	NSString *name;
	NSString *key;
	BOOL active;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, assign, getter=isActive) BOOL active;


+ (id) columnWithKey:(NSString *)newKey;
- (BOOL) hasName;


@end
