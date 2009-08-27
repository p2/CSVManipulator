//
//  GraphWindowController.h
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 27.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>


@interface GraphWindowController : NSWindowController {
	IBOutlet CPLayerHostingView *graphHostView;
    CPGraph *graph;
}

@property (nonatomic, retain) IBOutlet CPLayerHostingView *graphHostView;
@property (nonatomic, retain) CPGraph *graph;


@end
