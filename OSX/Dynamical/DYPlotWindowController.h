//
//  DYPlotViewController.h
//  Dynamical
//
//  Created by Matthew Jee on 2/7/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DYPlotViewController.h"
#import "DYPlotViewControllerDelegate.h"

#include "../../dynamical/parameter.h"
#include "../../dynamical/integrator.h"
#include "../../dynamical/dynamical.h"

using namespace dynam;
using namespace std;

@interface DYPlotWindowController : NSWindowController <NSWindowDelegate, DYPlotViewControllerDelegate>
{
    DynamicalSystem *lorenzSystem;
}

@property (nonatomic, strong) DYPlotViewController *plotViewController;

@property (assign) IBOutlet NSOpenGLView *openGLView;

@property (assign) IBOutlet NSSlider *paramSliderRho;
@property (assign) IBOutlet NSSlider *paramSliderSigma;
@property (assign) IBOutlet NSSlider *paramSliderBeta;

@property (assign) IBOutlet NSSlider *zoomSlider;

- (void)updateSeed:(Seed *)seed;

- (IBAction)changeParameter:(id)sender;
- (IBAction)changeZoom:(id)sender;
- (IBAction)addSeed:(id)sender;

@end
