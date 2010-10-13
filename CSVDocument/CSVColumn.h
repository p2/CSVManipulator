//
//  CSVColumn.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 24.08.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
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
