//
//  DYPlotViewController.h
//  Dynamical
//
//  Created by Matthew Jee on 2/7/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DYPlotView.h"
#import "DYPlotViewDelegate.h"

#include "../../dynamical/parameter.h"
#include "../../dynamical/integrator.h"
#include "../../dynamical/dynamical.h"

using namespace dynam;
using namespace std;

@interface DYPlotWindowController : NSWindowController
    <NSWindowDelegate, DYPlotViewDelegate, NSTableViewDataSource, NSTableViewDelegate>
{
    DynamicalSystem *dynamicalSystem;
    NSSliderCell *sliderCell;
}

@property (assign) IBOutlet DYPlotView *openGLView;
@property (assign) IBOutlet DYPlotView *parameterView;
@property (assign) IBOutlet NSTableView *sliderTableView;

- (void)updateSeed:(Seed *)seed;

- (IBAction)changeParameter:(id)sender;
- (IBAction)addSeed:(id)sender;

@end
