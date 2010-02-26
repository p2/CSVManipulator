//
//  CSVRow.m
//  QuickLookCSV
//
//  Created by Pascal Pfiffner on 03.07.09.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//  

#import "CSVRow.h"
#import "CSVDocument.h"
#import "CSVColumn.h"


@implementation CSVRow

static NSUInteger highestHeaderRowPos = 0;

@synthesize document;
@synthesize rowValues;
@dynamic isHeaderRow;
@synthesize headerRowPosition;


+ (id) rowForDocument:(CSVDocument *)forDocument
{
	CSVRow *row = [[[self alloc] init] autorelease];
	row.document = forDocument;
	return row;
}


+ (id) rowFromDict:(NSMutableDictionary *)dict forDocument:(CSVDocument *)forDocument
{
	CSVRow *row = [self rowForDocument:forDocument];
	
	if (dict) {
		row.rowValues = dict;
	}
	
	return row;
}

- (id) init
{
	self = [super init];
	if (self) {
		rowValues = [[NSMutableDictionary alloc] init];			// done manually to prevent copying the new object (self.rowValues is a copy property)
		headerRowPosition = UINT_MAX;
	}
	
	return self;
}

- (id) copyWithZone:(NSZone *)zone
{
	CSVRow *copy = [[[self class] allocWithZone:zone] init];
	copy.rowValues = rowValues;
	copy.document = document;
	
	return copy;
}

- (void) dealloc
{
	self.document = nil;
	self.rowValues = nil;
	
	[super dealloc];
}
#pragma mark -



#pragma mark KVC
- (BOOL) isHeaderRow
{
	return isHeaderRow;
}
- (void) setIsHeaderRow:(BOOL)isHeader
{
	if (isHeader != isHeaderRow) {
		NSUndoManager *undoManager = [[document document] undoManager];
		[[undoManager prepareWithInvocationTarget:self] setIsHeaderRow:isHeaderRow];
		//[undoManager setActionName:NSLocalizedString(@"Set Header Row", @"")];
		
		[self changeHeaderRow:isHeader];
		[document row:self didBecomeHeaderRow:isHeaderRow];
	}
}

- (void) changeHeaderRow:(BOOL)isHeader
{
	// this _silently_ changes the headerRow flag, only use from ourself or self.document!
	[self willChangeValueForKey:@"headerRow"];
	isHeaderRow = isHeader;
	[self didChangeValueForKey:@"headerRow"];
	
	if (isHeaderRow) {
		highestHeaderRowPos += 1;
		self.headerRowPosition = highestHeaderRowPos;
	}
	else {
		self.headerRowPosition = UINT_MAX;
	}
}
#pragma mark -



#pragma mark Returning Column Values
- (NSArray *) valuesForColumns:(NSArray *)columns
{
	if ((nil != columns) && (nil != rowValues)) {
		NSMutableArray *columnKeys = [NSMutableArray arrayWithCapacity:[columns count]];
		for (CSVColumn *column in columns) {
			[columnKeys addObject:column.key];
		}
		return [rowValues objectsForKeys:columnKeys notFoundMarker:@""];
	}
	
	return nil;
}

- (NSArray *) valuesForColumnKeys:(NSArray *)columnKeys
{
	if ((nil != columnKeys) && (nil != rowValues)) {
		return [rowValues objectsForKeys:columnKeys notFoundMarker:@""];
	}
	
	return nil;
}

- (NSString *) valuesForColumns:(NSArray *)columns combinedByString:(NSString *)sepString
{
	return [[self valuesForColumns:columns] componentsJoinedByString:sepString];
}

- (NSString *) valueForColumn:(CSVColumn *)column
{
	return [self valueForColumnKey:column.key];
}

- (NSString *) valueForColumnKey:(NSString *)columnKey
{
	if (nil != columnKey) {
		return [rowValues objectForKey:columnKey];
	}
	
	return nil;
}

- (BOOL) valueForColumnIsEmpty:(CSVColumn *)column
{
	return [self valueForColumnKeyIsEmpty:column.key];
}

- (BOOL) valueForColumnKeyIsEmpty:(NSString *)columnKey
{
	return [@"" isEqualToString:[self valueForColumnKey:columnKey]];
}


- (BOOL) isEmptyRow
{
	return ([rowValues count] < 1);
}
#pragma mark -



#pragma mark Setting Values
- (void) setValue:(id)value forColumn:(CSVColumn *)column
{
	[self setValue:value forColumnKey:column.key];
}

- (void) setValue:(id)value forColumnKey:(NSString *)key
{
	if (nil != key) {
		NSUndoManager *undoManager = [[document document] undoManager];
		[[undoManager prepareWithInvocationTarget:self] setValue:[self valueForColumnKey:key] forColumnKey:key];
		//[undoManager setActionName:NSLocalizedString(@"Set Value", nil)];
		
		value = (nil != value) ? value : [NSNull null];
		[rowValues setObject:value forKey:key];
	}
}

- (void) setValue:(id)value forKeyPath:(NSString *)keyPath
{
	// if rowValues get changed, we end up here
	if (0 == [keyPath rangeOfString:@"rowValues"].location) {
		NSUndoManager *undoManager = [[document document] undoManager];
		[[undoManager prepareWithInvocationTarget:self] setValue:[self valueForKeyPath:keyPath] forKeyPath:keyPath];
		//[undoManager setActionName:NSLocalizedString(@"Set Value", nil)];
		
		// if we were editing the cell, an undo operation would not be visible, so circumvent this manually
		if ([undoManager isUndoing]) {
			// TODO: Update Cell
			NSLog(@"Undoing row value change, update table cell content if currently editing...");
		}
	}
	
	[super setValue:value forKeyPath:keyPath];
}
#pragma mark -



#pragma mark Utilities
- (NSString *) description
{
	return [NSString stringWithFormat:@"%@ <0x%X>; %@", NSStringFromClass([self class]), self, rowValues];
}


@end
