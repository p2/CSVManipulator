//
//  PPStringFormat.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 29.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PPStringFormatRow;


@interface PPStringFormat : NSObject {
	NSString *name;
	
	NSString *prefix;
	NSString *suffix;
	
	PPStringFormatRow *headerFormat;
	PPStringFormatRow *valueFormat;
}

@property (copy) NSString *name;

@property (copy) NSString *prefix;
@property (copy) NSString *suffix;

@property (retain) PPStringFormatRow *headerFormat;
@property (retain) PPStringFormatRow *valueFormat;


+ (PPStringFormat *) csvFormat;
+ (PPStringFormat *) tabFormat;
+ (PPStringFormat *) flatXMLFormat;

- (NSString *) stringForRows:(NSArray *)csvRows includeHeaderRows:(BOOL)includeHeaderRows withColumnKeys:(NSArray *)keys;

- (NSString *) headerForColumnKeys:(NSArray *)keys values:(NSArray *)values;
- (NSString *) rowForColumnKeys:(NSArray *)keys values:(NSArray *)values;


@end
