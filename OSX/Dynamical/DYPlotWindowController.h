//
//  DYPlotViewController.h
//  Dynamical
//
//  Created by Matthew Jee on 2/7/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DYPlotView.h"
#import "DYParameterSpaceView.h"
#import "DYPlotViewDelegate.h"
#import "DYParameterSpaceViewDelegate.h"

@interface DYPlotWindowController : NSWindowController
    <NSWindowDelegate, DYPlotViewDelegate, NSTableViewDataSource,
    NSTableViewDelegate, DYParameterSpaceViewDelegate>

@property (assign) IBOutlet DYPlotView *plotView;
@property (assign) IBOutlet DYParameterSpaceView *parameterView;
@property (assign) IBOutlet NSTableView *sliderTableView;

- (id)initWithIntegrable:(Integrable)integrable parameters:(NSArray *)parameters;
- (id)initWithSourceString:(NSString *)source;
- (id)initWithContentsOfURL:(NSURL *)url;

- (void)updateSeed:(Seed *)seed;

- (IBAction)changeParameterStart:(id)sender;
- (IBAction)changeParameterEnd:(id)sender;
- (IBAction)addSeed:(id)sender;
- (IBAction)removeSeed:(id)sender;

@end
