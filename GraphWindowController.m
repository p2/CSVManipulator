//
//  GraphWindowController.m
//  CSVManipulator
//
//  Created by Pascal Pfiffner on 27.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GraphWindowController.h"
#import <QuartzCore/QuartzCore.h>


@implementation GraphWindowController

@synthesize graphHostView;
@synthesize graph;


- (id) initWithWindow:(NSWindow *)window
{
	self = [super initWithWindow:window];
	if (self) {
		
	}
	return self;
}

- (void) dealloc
{
	self.graphHostView = nil;
	self.graph = nil;
	
	[super dealloc];
}
#pragma mark -



#pragma mark KVC

#pragma mark -



#pragma mark GUI
- (void) awakeFromNib
{
	// Create graph from theme
	CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
	self.graph = [theme newGraph]; 
	graphHostView.hostedLayer = graph;
	
	// Setup plot space
	//--
	CGFloat minimumValueForXAxis = 0.0;
	CGFloat maximumValueForXAxis = 100.0;
	CGFloat minimumValueForYAxis = 0.0;
	CGFloat maximumValueForYAxis = 100.0;
	
	CGFloat majorIntervalLengthForX = 10.0;
	CGFloat majorIntervalLengthForY = 25.0;
	//--
	
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
	plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(minimumValueForXAxis) length:CPDecimalFromFloat(maximumValueForXAxis - minimumValueForXAxis)];
	plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(minimumValueForYAxis) length:CPDecimalFromFloat(maximumValueForYAxis - minimumValueForYAxis)];
	
	// setup axis sets
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
	CPXYAxis *x = axisSet.xAxis;
	x.majorIntervalLength = CPDecimalFromFloat(majorIntervalLengthForX);
	x.constantCoordinateValue = CPDecimalFromDouble(minimumValueForYAxis);
	x.minorTicksPerInterval = 5;
	
	CPXYAxis *y = axisSet.yAxis;
	y.majorIntervalLength = CPDecimalFromDouble(majorIntervalLengthForY);
	y.minorTicksPerInterval = 5;
	y.constantCoordinateValue = CPDecimalFromDouble(minimumValueForXAxis);
	
	CPLineStyle *borderLineStyle = [CPLineStyle lineStyle];
	borderLineStyle.lineColor = [CPColor colorWithGenericGray:0.2];
	borderLineStyle.lineWidth = 0.0f;
	
	CPBorderedLayer *borderedLayer = (CPBorderedLayer *)axisSet.overlayLayer;
	borderedLayer.borderLineStyle = borderLineStyle;
	borderedLayer.cornerRadius = 0.0f;
	
	// Create the main plot
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] initWithFrame:[graphHostView bounds]] autorelease];
	dataSourceLinePlot.identifier = @"Data Source Plot";
	dataSourceLinePlot.dataLineStyle.lineWidth = 1.f;
	dataSourceLinePlot.dataLineStyle.lineColor = [CPColor blackColor];
	
	[graph addPlot:dataSourceLinePlot];
	
	// Add plot symbols
	//	CPLineStyle *symbolLineStyle = [CPLineStyle lineStyle];
	//	symbolLineStyle.lineColor = [CPColor whiteColor];
	//	CPPlotSymbol *plotSymbol = [CPPlotSymbol ellipsePlotSymbol];
	//	plotSymbol.fill = [CPFill fillWithColor:[CPColor blueColor]];
	//	plotSymbol.lineStyle = symbolLineStyle;
	//    plotSymbol.size = CGSizeMake(10.0, 10.0);
	//    dataSourceLinePlot.plotSymbol = plotSymbol;
}


@end
