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


+ (id)rowForDocument:(CSVDocument *)forDocument
{
	CSVRow *row = [[[self alloc] init] autorelease];
	row.document = forDocument;
	return row;
}


+ (id)rowFromDict:(NSMutableDictionary *)dict forDocument:(CSVDocument *)forDocument
{
	CSVRow *row = [self rowForDocument:forDocument];
	
	if (dict) {
		row.rowValues = dict;
	}
	
	return row;
}

- (id)init
{
	self = [super init];
	if (self) {
		rowValues = [[NSMutableDictionary alloc] init];			// done manually to prevent copying the new object (self.rowValues is a copy property)
		headerRowPosition = UINT_MAX;
	}
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	CSVRow *copy = [[[self class] allocWithZone:zone] init];
	copy.rowValues = rowValues;
	copy.document = document;
	
	return copy;
}

- (void)dealloc
{
	self.document = nil;
	self.rowValues = nil;
	
	[super dealloc];
}



#pragma mark - KVC
- (BOOL)isHeaderRow
{
	return isHeaderRow;
}
- (void)setIsHeaderRow:(BOOL)isHeader
{
	if (isHeader != isHeaderRow) {
		NSUndoManager *undoManager = [[document document] undoManager];
		[[undoManager prepareWithInvocationTarget:self] setIsHeaderRow:isHeaderRow];
		[undoManager setActionName:NSLocalizedString(@"Header Row", nil)];
		
		[self changeHeaderRow:isHeader];
		[document row:self didBecomeHeaderRow:isHeaderRow];
	}
}

- (void)changeHeaderRow:(BOOL)isHeader
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



#pragma mark - Returning Column Values
- (NSArray *)valuesForColumns:(NSArray *)columns
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

- (NSArray *)valuesForColumnKeys:(NSArray *)columnKeys
{
	if ((nil != columnKeys) && (nil != rowValues)) {
		return [rowValues objectsForKeys:columnKeys notFoundMarker:@""];
	}
	
	return nil;
}

- (NSString *)valuesForColumns:(NSArray *)columns combinedByString:(NSString *)sepString
{
	return [[self valuesForColumns:columns] componentsJoinedByString:sepString];
}

- (NSString *)valueForColumn:(CSVColumn *)column
{
	return [self valueForColumnKey:column.key];
}

- (NSString *)valueForColumnKey:(NSString *)columnKey
{
	if (nil != columnKey) {
		return [rowValues objectForKey:columnKey];
	}
	
	return nil;
}

- (BOOL)valueForColumnIsEmpty:(CSVColumn *)column
{
	return [self valueForColumnKeyIsEmpty:column.key];
}

- (BOOL)valueForColumnKeyIsEmpty:(NSString *)columnKey
{
	return [@"" isEqualToString:[self valueForColumnKey:columnKey]];
}


- (BOOL)isEmptyRow
{
	return ([rowValues count] < 1);
}



#pragma mark - Setting Values
- (void)setValue:(id)value forColumn:(CSVColumn *)column
{
	[self setValue:value forColumnKey:column.key];
}

- (void)setValue:(id)value forColumnKey:(NSString *)key
{
	if (nil != key) {
		if (document.parseSuccessful) {
			NSUndoManager *undoManager = [[document document] undoManager];
			[[undoManager prepareWithInvocationTarget:self] setValue:[self valueForColumnKey:key] forColumnKey:key];
			[undoManager setActionName:NSLocalizedString(@"Value Change", nil)];
		}
		
		if (nil != value) {
			[rowValues setObject:value forKey:key];
		}
		else {
			[rowValues removeObjectForKey:key];
		}
		
		// if we are a header row, maybe the column name changed
		if (document.parseSuccessful && isHeaderRow) {
			[document updateColumnNames];
		}
	}
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath
{
	// if rowValues get changed, we end up here
	if (0 == [keyPath rangeOfString:@"rowValues"].location) {
		NSUndoManager *undoManager = [[document document] undoManager];
		[[undoManager prepareWithInvocationTarget:self] setValue:[self valueForKeyPath:keyPath] forKeyPath:keyPath];
		[undoManager setActionName:NSLocalizedString(@"Value Change", nil)];
		
		// if we were editing the cell, an undo operation would not be visible, so circumvent this manually
		if ([undoManager isUndoing]) {
			// TODO: Update Cell
			NSLog(@"Undoing row value change, update table cell content if currently editing...");
		}
	}
	
	[super setValue:value forKeyPath:keyPath];
	
	// if we are a header row, maybe the column name changed
	if (isHeaderRow) {
		[document updateColumnNames];
	}
}



#pragma mark - Utilities
- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ <%p>; %@", NSStringFromClass([self class]), self, rowValues];
}


@end
