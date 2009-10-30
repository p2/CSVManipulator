//
//  PPStringFormat.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 29.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PPStringFormatRow;


@interface PPStringFormat : NSObject <NSCopying> {
	BOOL systemFormat;						// indicates whether this is a system format or not
	NSString *name;
	NSString *formatDescription;
	
	NSString *prefix;						// what to put before the content, e.g. <root>
	NSString *suffix;						// obviously what to put after, e.g. </root>
	
	PPStringFormatRow *headerFormat;		// the formatRow that formats rows marked as header
	PPStringFormatRow *valueFormat;			// the formatRow that formats arbitrary rows
}

@property (nonatomic, assign, getter=isSystemFormat) BOOL systemFormat;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *formatDescription;

@property (nonatomic, copy) NSString *prefix;
@property (nonatomic, copy) NSString *suffix;

@property (nonatomic, retain) PPStringFormatRow *headerFormat;
@property (nonatomic, retain) PPStringFormatRow *valueFormat;


+ (PPStringFormat *) csvFormat;
+ (PPStringFormat *) tabFormat;
+ (PPStringFormat *) flatXMLFormat;

- (NSString *) stringForRows:(NSArray *)csvRows includeHeaderRows:(BOOL)includeHeaderRows withColumns:(NSArray *)columns;

- (NSString *) headerForColumnKeys:(NSArray *)keys values:(NSArray *)values;
- (NSString *) rowForColumnKeys:(NSArray *)keys values:(NSArray *)values;


@end
