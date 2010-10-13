//
//  PPStringFormat.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 29.08.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import <Cocoa/Cocoa.h>
@class PPStringFormatRow;


@interface PPStringFormat : NSObject <NSCopying, NSCoding> {
	BOOL systemFormat;						// indicates whether this is a system format or not
	NSString *name;
	NSString *type;
	NSString *formatDescription;
	
	NSString *prefix;						// what to put before the content, e.g. <root>
	NSString *suffix;						// obviously what to put after, e.g. </root>
	
	BOOL exportHeaders;						// if NO header rows will not be exported
	BOOL useHeaderNamesAsKey;				// if YES the column names will be used as keys
	PPStringFormatRow *headerFormat;		// the formatRow that formats rows marked as header
	PPStringFormatRow *valueFormat;			// the formatRow that formats arbitrary rows
	
	NSURL *fileURL;
}

@property (nonatomic, assign, getter=isSystemFormat) BOOL systemFormat;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *formatDescription;

@property (nonatomic, copy) NSString *prefix;
@property (nonatomic, copy) NSString *suffix;

@property (nonatomic, assign) BOOL exportHeaders;
@property (nonatomic, assign) BOOL useHeaderNamesAsKey;
@property (nonatomic, retain) PPStringFormatRow *headerFormat;
@property (nonatomic, retain) PPStringFormatRow *valueFormat;

@property (nonatomic, readwrite, copy) NSURL *fileURL;


+ (PPStringFormat *) csvFormat;
+ (PPStringFormat *) tabFormat;
+ (PPStringFormat *) flatXMLFormat;
+ (PPStringFormat *) sqlFormat;

- (NSString *) stringForRows:(NSArray *)csvRows andColumns:(NSArray *)columns;
- (NSString *) headerForColumnKeys:(NSArray *)keys values:(NSArray *)values;
- (NSString *) rowForColumnKeys:(NSArray *)keys values:(NSArray *)values;

+ (PPStringFormat *) formatFromFile:(NSURL *)aFileURL error:(NSError **)outError;
- (BOOL) writeToFile:(NSURL *)aFileURL error:(NSError **)outError;
- (BOOL) save:(NSError **)outError;
- (BOOL) deleteFile:(NSError **)outError;


@end
