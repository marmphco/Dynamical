//
//  DYPlotViewController.m
//  Dynamical
//
//  Created by Matthew Jee on 2/7/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import "DYPlotWindowController.h"
#import "DYParameterTableView.h"

#include "../../dynamical/parameter.h"
#include "../../dynamical/integrator.h"
#include "../../dynamical/dynamical.h"

using namespace dynam;
using namespace std;

@interface DYPlotWindowController ()
{
    DynamicalSystem *dynamicalSystem;
    JSGlobalContextRef jsContext;
}

@end

@implementation DYPlotWindowController

- (id)initWithIntegrable:(Integrable)integrable parameters:(NSArray *)parameters
{
    self = [super initWithWindowNibName:@"PlotWindow"];
    if (self) {
        Integrator *integrator = new RK4Integrator(0.01);
        
        dynamicalSystem = new DynamicalSystem(integrable, integrator, (int)parameters.count);
        
        for (int i = 0; i < parameters.count; ++i) {
            NSString *name = parameters[i];
            dynamicalSystem->parameter(i).name = [name UTF8String];
        }
    }
    return self;
}

- (id)initWithSourceString:(NSString *)source
{
    jsContext = DYJavascriptCreateContext([source UTF8String]);
    NSArray *parameters = DYJavascriptGetParameters(jsContext);
    self = [self initWithIntegrable:DYJavascriptGetIntegrable() parameters:parameters];
    return self;
}

- (id)initWithContentsOfURL:(NSURL *)url
{
    NSError *error;
    NSString *source = [NSString stringWithContentsOfURL:url
                                                encoding:NSUTF8StringEncoding
                                                   error:&error];
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    
    self = [self initWithSourceString:source];
    return self;
}

- (void)dealloc
{
    if (jsContext) {
        JSGlobalContextRelease(jsContext);
    }
}

- (void)windowDidLoad
{
    NSSize aspectRatio;
    aspectRatio.width = 1038;
    aspectRatio.height = 400;
    [self.window setContentAspectRatio:aspectRatio];
    
    [self.plotView addSeed]->transform.position = Vector3(1, 1, 1);
    
    [self.plotView enumerateSeedsWithBlock:^(Seed *seed) {
        [self updateSeed:seed];
    }];
}

- (void)updateSeed:(Seed *)seed
{
    int count = 1000;
    int evolutions = seed->evolutionCount;
    
    Parameter &sigma = dynamicalSystem->parameter(LORENZ_SIGMA);
    Parameter &rho = dynamicalSystem->parameter(LORENZ_RHO);
    Parameter &beta = dynamicalSystem->parameter(LORENZ_BETA);
    if (jsContext) {
        DYJavascriptSetCurrentContext(jsContext);
    }
    
    for (int j = 0; j < evolutions; j++) {
        
        GLfloat vertices[count*6];
        GLuint indices[count];
        Vector3 p = seed->transform.position;
        
        double s = j*1.0/evolutions;
        sigma.setValue(sigma.minValue()+(sigma.maxValue()-sigma.minValue())*s);
        rho.setValue(rho.minValue()+(rho.maxValue()-rho.minValue())*s);
        beta.setValue(beta.minValue()+(beta.maxValue()-beta.minValue())*s);
        
        double t = 0.0;
        for (int i = 0; i < count; i++) {
            Vector3 op = p;
            p = dynamicalSystem->evaluate(p, t);
            
            vertices[i*6] = (GLfloat)p.x;
            vertices[i*6+1] = (GLfloat)p.y;
            vertices[i*6+2] = (GLfloat)p.z;
            
            vertices[i*6+3] = s;//(GLfloat)p.x-op.x;
            vertices[i*6+4] = s;//(GLfloat)p.y-op.y;
            vertices[i*6+5] = s;//(GLfloat)p.z-op.z;
            
            indices[i] = i;
            t += 0.01;
        }
        [self.plotView replacePathWithID:seed->pathIDs[j]
                                vertices:vertices
                                 indices:indices
                             vertexCount:count*2
                              indexCount:count];
    }
}

- (void)seedWasMoved:(Seed *)seed
{
    [self updateSeed:seed];
}

- (IBAction)changeParameter:(id)sender
{
    NSSlider *slider = (NSSlider *)sender;
    dynamicalSystem->parameter((int)slider.tag).setValue([slider doubleValue]);
    
    [self.plotView enumerateSeedsWithBlock:^(Seed *seed) {
        [self updateSeed:seed];
    }];
    
    NSIndexSet *rowIndices = [NSIndexSet indexSetWithIndex:slider.tag];
    NSIndexSet *colIndices = [NSIndexSet indexSetWithIndex:0];
    [self.sliderTableView reloadDataForRowIndexes:rowIndices columnIndexes:colIndices];
    [self.plotView redraw];
}

- (IBAction)addSeed:(id)sender
{
    [self updateSeed:[self.plotView addSeed]];
    [self.plotView redraw];
}

- (IBAction)removeSeed:(id)sender
{
    [self.plotView removeSelectedSeed];
    [self.plotView redraw];
}

#pragma mark -
#pragma mark DYParameterSpaceViewDelegate

- (void)parameterSpaceViewBoundsDidChange:(DYParameterSpaceView *)view
{
    dynamicalSystem->parameter(0).setMinValue([view minValueForAxis:0]);
    dynamicalSystem->parameter(0).setMaxValue([view maxValueForAxis:0]);
    dynamicalSystem->parameter(1).setMinValue([view minValueForAxis:1]);
    dynamicalSystem->parameter(1).setMaxValue([view maxValueForAxis:1]);
    dynamicalSystem->parameter(2).setMinValue([view minValueForAxis:2]);
    dynamicalSystem->parameter(2).setMaxValue([view maxValueForAxis:2]);
    [self.sliderTableView reloadData];
    [self.plotView enumerateSeedsWithBlock:^(Seed *seed) {
        [self updateSeed:seed];
    }];
    [self.plotView redraw];
}

#pragma mark -
#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return dynamicalSystem->parameterCount();
}

#pragma mark -
#pragma mark NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    Parameter &parameter = dynamicalSystem->parameter((int)row);

    DYParameterTableView *view = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    view.nameField.stringValue = [NSString stringWithUTF8String:parameter.name.c_str()];
    [view.valueField setFloatValue:parameter.value()];
    [view.minField setFloatValue:parameter.minValue()];
    [view.maxField setFloatValue:parameter.maxValue()];
    [view.slider setMaxValue:parameter.maxValue()];
    [view.slider setMinValue:parameter.minValue()];
    [view.slider setDoubleValue:parameter.value()];
    view.slider.tag = row;
    return view;
}

@end
