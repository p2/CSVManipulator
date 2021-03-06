//
//  BC.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 09.06.08.
//  This sourcecode is released under the Apache License, Version 2.0
//  http://www.apache.org/licenses/LICENSE-2.0.html
//

#import "BC.h"

@implementation BC

+ (NSString *) performMathOperation:(NSString *)op
{
	if ((nil == op) || ([op length] <= 0)) {
		return nil;
	}
	
	NSTask *task = [[NSTask alloc] init];
	NSPipe *inPipe = [NSPipe pipe];
	NSPipe *outPipe = [NSPipe pipe];
	NSFileHandle *inHandle = [inPipe fileHandleForWriting];
	NSFileHandle *outHandle = [outPipe fileHandleForReading];
	NSData *inData, *outData;
	NSString *outString;
	
	// the input must end with a new line character or we'll get syntax errors
	if ([op characterAtIndex:[op length]-1] != '\n') {
		op = [op stringByAppendingString:@"\n"];
	}
	inData = [op dataUsingEncoding:NSUTF8StringEncoding];
	
	[task setLaunchPath:@"/usr/bin/bc"];
	[task setStandardOutput:outPipe];
	[task setStandardError:outPipe];
	[task setStandardInput:inPipe];
	[task launch];
	
	[inHandle writeData:[@"scale=10\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[inHandle writeData:inData];
	[inHandle closeFile];
	
	outData = [outHandle readDataToEndOfFile];
	[task waitUntilExit];
	[task release];
	
	if ((nil != outData) && ([outData length] > 0)) {
		outString = [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
		if (outString) {
			return [outString autorelease];
		}
	}
	
	return nil;
}


@end
