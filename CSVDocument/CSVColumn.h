//
//  CSVColumn.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 24.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#ifdef IPHONE
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif


@interface CSVColumn : NSObject {
	NSString *name;				// the name to display
	NSString *key;				// a unique key
	NSString *type;				// type of the values (NSString, NSNumber, NSDate) TODO: implement!
	BOOL active;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign, getter=isActive) BOOL active;


+ (id) columnWithKey:(NSString *)newKey;
- (BOOL) hasName;
- (NSString *) fullName;


@end
