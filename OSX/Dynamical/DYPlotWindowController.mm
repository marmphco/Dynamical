//
//  DYPlotViewController.m
//  Dynamical
//
//  Created by Matthew Jee on 2/7/14.
//  Copyright (c) 2014 mcjee. All rights reserved.
//

#import "DYPlotWindowController.h"
#import "DYParameterTableView.h"
#import "DYJavascriptEngine.h"

#include "../../dynamical/parameter.h"
#include "../../dynamical/integrator.h"
#include "../../dynamical/dynamical.h"

using namespace dynam;
using namespace std;

@interface DYPlotWindowController ()
{
    DynamicalSystem *dynamicalSystem;
    Integrator *_integrator;
    NSInteger _pathStepLength;
    NSInteger _evolutionCount;
    DYJavascriptEngine *jsEngine;
    
    NSString *_title;
    
    int _axisToParameterMapping[3];
}

@end

@implementation DYPlotWindowController

#pragma mark -
#pragma mark Initializers

- (id)initWithIntegrable:(Integrable)integrable parameters:(NSArray *)parameters
{
    self = [super initWithWindowNibName:@"PlotWindow"];
    if (self) {
        _evolutionCount = 10;
        _pathStepLength = 10.0;
        _integrator = new RK4Integrator(0.01);
        dynamicalSystem = new DynamicalSystem(integrable, _integrator, (int)parameters.count);
        
        _axisToParameterMapping[0] = -1;
        _axisToParameterMapping[1] = -1;
        _axisToParameterMapping[2] = -1;
        for (int i = 0; i < parameters.count; ++i) {
            NSString *name = parameters[i];
            dynamicalSystem->parameter(i).name = [name UTF8String];
            
            // add to mapping defaults if posssible
            if (i < 3) {
                _axisToParameterMapping[i] = i;
            }
        }

    }
    return self;
}

- (id)initWithSourceString:(NSString *)source
{
    NSError *error;
    jsEngine = [[DYJavascriptEngine alloc] initWithSourceString:source error:&error];
    if (error) {
        [[NSAlert alertWithError:error] runModal];
        return nil;
    }
    
    NSArray *parameters = [jsEngine parameterNamesOrError:&error];
    if (error) {
        [[NSAlert alertWithError:error] runModal];
        return nil;
    }
    self = [self initWithIntegrable:[DYJavascriptEngine integrable] parameters:parameters];
    return self;
}

- (id)initWithContentsOfURL:(NSURL *)url
{
    NSError *error;
    NSString *source = [NSString stringWithContentsOfURL:url
                                                encoding:NSUTF8StringEncoding
                                                   error:&error];
    if (error) {
        [[NSAlert alertWithError:error] runModal];
        return nil;
    }
    
    _title = [url lastPathComponent];
    self = [self initWithSourceString:source];
    return self;
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc
{
    delete _integrator;
    delete dynamicalSystem;
}

#pragma mark -
#pragma mark Overrides

- (void)windowDidLoad
{
    [self.xPopupButton addItemWithTitle:@"None"];
    [self.yPopupButton addItemWithTitle:@"None"];
    [self.zPopupButton addItemWithTitle:@"None"];
    for (int i = 0; i < dynamicalSystem->parameterCount(); ++i) {
        NSString *name = [NSString stringWithUTF8String:dynamicalSystem->parameter(i).name.c_str()];
        [self.xPopupButton addItemWithTitle:name];
        [self.yPopupButton addItemWithTitle:name];
        [self.zPopupButton addItemWithTitle:name];
    }
    [self.xPopupButton selectItemAtIndex:_axisToParameterMapping[0]+1];
    [self.yPopupButton selectItemAtIndex:_axisToParameterMapping[1]+1];
    [self.zPopupButton selectItemAtIndex:_axisToParameterMapping[2]+1];

    [self.plotView addSeed]->transform.position = Vector3(1, 1, 1);
    
    [self.plotView enumerateSeedsWithBlock:^(Seed *seed) {
        [self updateSeed:seed];
    }];
    
    if (_title) {
        [self.window setTitle:_title];
    }
    
    // hack to get window to do initial draw
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.plotView update];
        [self.parameterView update];
    });
}

#pragma mark -
#pragma mark Other

- (void)updateSeed:(Seed *)seed
{
    int count = _pathStepLength/_integrator->step();
    int evolutions = seed->evolutionCount;
    NSError *error;

    if (jsEngine) {
        [jsEngine makeCurrentEngineOrError:&error];
        if (error) {
            [[NSAlert alertWithError:error] runModal];
        }
    }
    
    // A NECESSARY EVIL (because of the dumb way that paths are stored
    for (int i = 0; i < evolutions; i++) {
        GLfloat vertices[] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
        GLuint indices[] = {0};
        [self.plotView replacePathWithID:seed->pathIDs[i]
                                vertices:vertices
                                 indices:indices
                             vertexCount:1
                              indexCount:1
                                  sValue:0.0];
    }
    
    for (int j = 0; j < _evolutionCount; j++) {
        
        GLfloat vertices[count*6];
        GLuint indices[count];
        Vector3 p = seed->transform.position;
        
        double s = j*1.0/(_evolutionCount-1.0);
        for (int i = 0; i < dynamicalSystem->parameterCount(); ++i) {
            Parameter &param = dynamicalSystem->parameter(i);
            param.setValue(param.minValue()+(param.maxValue()-param.minValue())*s);
        }
        
        if (jsEngine) {
            [jsEngine prepareToEvaluateSystem:dynamicalSystem error:&error];
            if (error) {
                [[NSAlert alertWithError:error] runModal];
            }
        }
        
        double t = 0.0;
        Vector3 op = p;
        for (int i = 0; i < count; i++) {
            p = dynamicalSystem->evaluate(p, t);
            
            vertices[i*6] = (GLfloat)p.x;
            vertices[i*6+1] = (GLfloat)p.y;
            vertices[i*6+2] = (GLfloat)p.z;
            
            vertices[i*6+3] = p.x-op.x;
            vertices[i*6+4] = p.y-op.y;
            vertices[i*6+5] = p.z-op.z;
            
            indices[i] = i;
            t += 0.01;
        }
        [self.plotView replacePathWithID:seed->pathIDs[j]
                                vertices:vertices
                                 indices:indices
                             vertexCount:count
                              indexCount:count
                                  sValue:s];
    }
}

- (IBAction)changeParameterMapping:(id)sender
{
    _axisToParameterMapping[DYXAxis] = (int)[self.xPopupButton indexOfSelectedItem]-1;
    _axisToParameterMapping[DYYAxis] = (int)[self.yPopupButton indexOfSelectedItem]-1;
    _axisToParameterMapping[DYZAxis] = (int)[self.zPopupButton indexOfSelectedItem]-1;
    [self parameterSpaceViewBoundsDidChange:self.parameterView];
}

- (IBAction)changeParameterStart:(id)sender
{
    NSSlider *slider = (NSSlider *)sender;
    dynamicalSystem->parameter((int)slider.tag).setMinValue([slider doubleValue]);
    
    [self.plotView enumerateSeedsWithBlock:^(Seed *seed) {
        [self updateSeed:seed];
    }];
    
    // change parameter in parameter space view
    for (int i = 0; i < 3; ++i) {
        int parameter = _axisToParameterMapping[i];
        if (parameter == (int)slider.tag) {
            [self.parameterView setStartValue:[slider doubleValue] forAxis:i];
        }
    }
    NSIndexSet *rowIndices = [NSIndexSet indexSetWithIndex:slider.tag];
    NSIndexSet *colIndices = [NSIndexSet indexSetWithIndex:0];
    [self.sliderTableView reloadDataForRowIndexes:rowIndices columnIndexes:colIndices];
    [self.plotView redraw];
    [self.parameterView redraw];
}

- (IBAction)changeParameterEnd:(id)sender
{
    NSSlider *slider = (NSSlider *)sender;
    dynamicalSystem->parameter((int)slider.tag).setMaxValue([slider doubleValue]);
    
    [self.plotView enumerateSeedsWithBlock:^(Seed *seed) {
        [self updateSeed:seed];
    }];
    
    // change parameter in parameter space view
    for (int i = 0; i < 3; ++i) {
        int parameter = _axisToParameterMapping[i];
        if (parameter == (int)slider.tag) {
            [self.parameterView setEndValue:[slider doubleValue] forAxis:i];
        }
    }
    [self.parameterView setEndValue:[slider doubleValue] forAxis:(int)slider.tag];
    
    NSIndexSet *rowIndices = [NSIndexSet indexSetWithIndex:slider.tag];
    NSIndexSet *colIndices = [NSIndexSet indexSetWithIndex:0];
    [self.sliderTableView reloadDataForRowIndexes:rowIndices columnIndexes:colIndices];
    [self.plotView redraw];
    [self.parameterView redraw];
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

- (IBAction)changeEvolutions:(id)sender
{
    _evolutionCount = [sender intValue];
    [self.plotView enumerateSeedsWithBlock:^(Seed *seed) {
        [self updateSeed:seed];
    }];
    [self.plotView redraw];
}

- (IBAction)changeIntegrationStep:(id)sender
{
    _integrator->setStep([sender doubleValue]);

    [self.plotView enumerateSeedsWithBlock:^(Seed *seed) {
        [self updateSeed:seed];
    }];
    [self.plotView redraw];
}

#pragma mark -
#pragma mark DYPlotViewDelegate

- (void)plotView:(DYPlotView *)plotView seedWasMoved:(Seed *)seed
{
    [self updateSeed:seed];
}

- (void)plotView:(DYPlotView *)plotView seedWasSelected:(int)objectID
{
    [self.removeSeedButton setEnabled:YES];
}

- (void)plotView:(DYPlotView *)plotView seedWasDeselected:(int)objectID
{
    [self.removeSeedButton setEnabled:NO];
}

#pragma mark -
#pragma mark DYParameterSpaceViewDelegate

- (void)parameterSpaceViewBoundsDidChange:(DYParameterSpaceView *)view
{
    for (int i = 0; i < 3; ++i) {
        int parameter = _axisToParameterMapping[i];
        if (parameter != -1) {
            dynamicalSystem->parameter(parameter).setMinValue([view minValueForAxis:i]);
            dynamicalSystem->parameter(parameter).setMaxValue([view maxValueForAxis:i]);
        }
    }
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
    [view.minField setFloatValue:parameter.minValue()];
    [view.maxField setFloatValue:parameter.maxValue()];
    view.maxField.tag = row;
    view.minField.tag = row;
    return view;
}

- (BOOL)validateProposedFirstResponder:(NSResponder *)responder forEvent:(NSEvent *)event
{
    return YES;
}

@end
