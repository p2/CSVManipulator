//
//  PPExportFormat.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 29.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PPExportFormat : NSObject {

}


+ (PPExportFormat *) csvFormat;
+ (PPExportFormat *) tabFormat;


@end
